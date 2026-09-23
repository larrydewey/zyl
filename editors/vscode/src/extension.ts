import * as vscode from 'vscode';
import * as path from 'path';
import * as fs from 'fs';
import {
    LanguageClient,
    LanguageClientOptions,
    ServerOptions,
    State,
} from 'vscode-languageclient/node';

let client: LanguageClient | undefined;
let statusItem: vscode.StatusBarItem;
let evalOutput: vscode.OutputChannel;

/**
 * Where zyl-lsp might be, in the order worth trying:
 *
 *  1. an explicit `zyl.lsp.path` setting, which always wins;
 *  2. $ZYL_HOME/bin, then ~/.zyl/bin -- where install.sh puts it;
 *  3. build/boot/ inside an open workspace folder, which is where
 *     ./boot.sh leaves it when you are working on the compiler itself;
 *  4. plain `zyl-lsp`, resolved through $PATH.
 *
 * Returning the bare name at the end rather than nothing means a
 * PATH install still works with no configuration at all.
 */
function findServer(): string {
    const configured = vscode.workspace.getConfiguration('zyl').get<string>('lsp.path');
    if (configured && configured.length > 0) {
        return configured;
    }

    const candidates: string[] = [];
    const zylHome = process.env.ZYL_HOME;
    if (zylHome) {
        candidates.push(path.join(zylHome, 'bin', 'zyl-lsp'));
        candidates.push(path.join(zylHome, 'zyl-lsp'));
    }
    const home = process.env.HOME || process.env.USERPROFILE;
    if (home) {
        candidates.push(path.join(home, '.zyl', 'bin', 'zyl-lsp'));
    }
    for (const folder of vscode.workspace.workspaceFolders ?? []) {
        candidates.push(path.join(folder.uri.fsPath, 'build', 'boot', 'zyl-lsp'));
    }

    for (const candidate of candidates) {
        try {
            if (fs.existsSync(candidate)) {
                return candidate;
            }
        } catch {
            // An unreadable candidate is simply not the one.
        }
    }
    return 'zyl-lsp';
}

function findCompiler(): string {
    const configured = vscode.workspace.getConfiguration('zyl').get<string>('compiler.path');
    if (configured && configured.length > 0) {
        return configured;
    }
    const home = process.env.HOME || process.env.USERPROFILE;
    const candidates = [
        process.env.ZYL_HOME ? path.join(process.env.ZYL_HOME, 'bin', 'zyl') : '',
        home ? path.join(home, '.zyl', 'bin', 'zyl') : '',
    ].filter((p) => p.length > 0);
    for (const candidate of candidates) {
        try {
            if (fs.existsSync(candidate)) {
                return candidate;
            }
        } catch {
            // Ignore and keep looking.
        }
    }
    return 'zyl';
}

function setStatus(text: string, tooltip: string, warn: boolean): void {
    statusItem.text = `$(symbol-namespace) ${text}`;
    statusItem.tooltip = tooltip;
    statusItem.backgroundColor = warn
        ? new vscode.ThemeColor('statusBarItem.warningBackground')
        : undefined;
    statusItem.show();
}

async function startClient(context: vscode.ExtensionContext): Promise<void> {
    const config = vscode.workspace.getConfiguration('zyl');
    if (!config.get<boolean>('lsp.enable', true)) {
        setStatus('Zyl (server off)', 'zyl.lsp.enable is false', false);
        return;
    }

    const command = findServer();
    const args = config.get<string[]>('lsp.arguments', []);

    const serverOptions: ServerOptions = {
        command,
        args,
        options: { env: { ...process.env } },
    };

    const clientOptions: LanguageClientOptions = {
        documentSelector: [{ scheme: 'file', language: 'zyl' }],
        synchronize: {
            fileEvents: vscode.workspace.createFileSystemWatcher('**/*.zyl'),
            configurationSection: 'zyl',
        },
        outputChannel: vscode.window.createOutputChannel('Zyl Language Server'),
        initializationOptions: {
            inlayHints: {
                parameterNames: config.get<boolean>('inlayHints.parameterNames', true),
            },
        },
    };

    client = new LanguageClient('zyl', 'Zyl Language Server', serverOptions, clientOptions);
    client.onDidChangeState((event) => {
        if (event.newState === State.Running) {
            setStatus('Zyl', `Language server running (${command})`, false);
        } else if (event.newState === State.Stopped) {
            setStatus('Zyl (stopped)', 'Language server is not running', true);
        }
    });

    setStatus('Zyl (starting)', `Starting ${command}`, false);
    try {
        // start() resolves once the server is ready in
        // vscode-languageclient v8 and later; the separate onReady()
        // this used to call was removed in that version.
        await client.start();
    } catch (err) {
        client = undefined;
        setStatus('Zyl (not found)', `Could not start ${command}`, true);
        const choice = await vscode.window.showErrorMessage(
            `Zyl: could not start the language server (${command}). ` +
                'Build it with ./boot.sh, or install it with ./install.sh.',
            'Open Settings',
        );
        if (choice === 'Open Settings') {
            void vscode.commands.executeCommand('workbench.action.openSettings', 'zyl.lsp.path');
        }
    }
}

async function stopClient(): Promise<void> {
    if (client) {
        await client.stop();
        client = undefined;
    }
}

export async function activate(context: vscode.ExtensionContext): Promise<void> {
    statusItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
    statusItem.command = 'zyl.showServerLog';
    context.subscriptions.push(statusItem);

    evalOutput = vscode.window.createOutputChannel('Zyl');
    context.subscriptions.push(evalOutput);

    await startClient(context);

    context.subscriptions.push(
        vscode.commands.registerCommand('zyl.restartLSP', async () => {
            await stopClient();
            await startClient(context);
        }),
        vscode.commands.registerCommand('zyl.stopLSP', async () => {
            await stopClient();
            setStatus('Zyl (stopped)', 'Language server stopped', true);
        }),
        vscode.commands.registerCommand('zyl.showServerLog', () => {
            client?.outputChannel.show(true);
        }),
        vscode.commands.registerCommand('zyl.evalDocument', () => runCurrentFile()),
    );

    // A changed server path or a flipped enable switch only takes
    // effect on a restart, so do the restart rather than leaving the
    // setting looking broken.
    context.subscriptions.push(
        vscode.workspace.onDidChangeConfiguration(async (event) => {
            if (
                event.affectsConfiguration('zyl.lsp.path') ||
                event.affectsConfiguration('zyl.lsp.enable') ||
                event.affectsConfiguration('zyl.lsp.arguments')
            ) {
                await stopClient();
                await startClient(context);
            }
        }),
    );

    context.subscriptions.push(
        vscode.tasks.registerTaskProvider('zyl', {
            provideTasks: () => buildTasks(),
            resolveTask: (task) => task,
        }),
    );
}

/** `zyl <file> -o <file without extension>` for every open .zyl file. */
function buildTasks(): vscode.Task[] {
    const compiler = findCompiler();
    const tasks: vscode.Task[] = [];
    for (const document of vscode.workspace.textDocuments) {
        if (document.languageId !== 'zyl' || document.uri.scheme !== 'file') {
            continue;
        }
        const file = document.uri.fsPath;
        const output = file.replace(/\.zyl$/, '');
        const task = new vscode.Task(
            { type: 'zyl', file },
            vscode.TaskScope.Workspace,
            `build ${path.basename(file)}`,
            'zyl',
            new vscode.ShellExecution(compiler, [file, '-o', output]),
        );
        task.group = vscode.TaskGroup.Build;
        tasks.push(task);
    }
    return tasks;
}

/**
 * Compile and run the active buffer through the server's own
 * `zyl.evalDocument` command, so the text that runs is what is on
 * screen rather than what was last saved.
 */
async function runCurrentFile(): Promise<void> {
    const editor = vscode.window.activeTextEditor;
    if (!editor || editor.document.languageId !== 'zyl') {
        void vscode.window.showWarningMessage('Zyl: no active Zyl file.');
        return;
    }
    if (!client) {
        void vscode.window.showWarningMessage(
            'Zyl: the language server is not running, so the file cannot be run from here.',
        );
        return;
    }

    const uri = editor.document.uri.toString();
    evalOutput.show(true);
    evalOutput.appendLine(`--- running ${editor.document.fileName} ---`);
    try {
        const result = (await client.sendRequest('workspace/executeCommand', {
            command: 'zyl.evalDocument',
            arguments: [uri],
        })) as { ok: boolean; output: string } | null;

        if (!result) {
            evalOutput.appendLine('--- the server returned nothing ---');
            return;
        }
        evalOutput.append(result.output);
        if (!result.ok) {
            evalOutput.appendLine('--- compile or run failed ---');
        }
    } catch (err) {
        evalOutput.appendLine(`--- request failed: ${err} ---`);
    }
}

export function deactivate(): Thenable<void> | undefined {
    return client?.stop();
}
