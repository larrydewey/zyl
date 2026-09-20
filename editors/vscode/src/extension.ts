import * as vscode from 'vscode';
import * as path from 'path';
import * as fs from 'fs';
import {
    LanguageClient,
    LanguageClientOptions,
    ServerOptions,
} from 'vscode-languageclient/node';

let lspClient: LanguageClient | undefined;

export function activate(context: vscode.ExtensionContext) {
    const config = vscode.workspace.getConfiguration('zyl');
    const lspPath = config.get<string>('lsp.path') || 'zyl-lsp';
    const trace = config.get<string>('lsp.trace.server') || 'off';

    // Find the LSP binary
    let serverPath = lspPath;
    if (!path.isAbsolute(lspPath)) {
        // Check in ~/.zyl/bin
        const home = process.env.HOME || process.env.USERPROFILE;
        if (home) {
            const candidate = path.join(home, '.zyl', 'bin', 'zyl-lsp');
            if (fs.existsSync(candidate)) {
                serverPath = candidate;
            }
        }
        // Check in build/boot relative to workspace
        const workspaceFolders = vscode.workspace.workspaceFolders;
        if (workspaceFolders) {
            for (const folder of workspaceFolders) {
                const candidate = path.join(folder.uri.fsPath, 'build', 'boot', 'zyl-lsp');
                if (fs.existsSync(candidate)) {
                    serverPath = candidate;
                    break;
                }
            }
        }
    }

    const serverOptions: ServerOptions = {
        command: serverPath,
        args: [],
        options: {
            env: { ...process.env }
        }
    };

    const clientOptions: LanguageClientOptions = {
        documentSelector: [{ scheme: 'file', language: 'zyl' }],
        synchronize: {
            fileEvents: vscode.workspace.createFileSystemWatcher('**/*.zyl')
        },
        initializationOptions: {},
    };

    lspClient = new LanguageClient(
        'zyl',
        'Zyl Language Server',
        serverOptions,
        clientOptions
    );

    // start() itself resolves once the server is ready in
    // vscode-languageclient v8+ (the separate onReady() this used to
    // call was removed in that version).
    lspClient.start();

    context.subscriptions.push(
        vscode.commands.registerCommand('zyl.restartLSP', () => {
            if (lspClient) {
                lspClient.stop().then(() => lspClient!.start());
            }
        })
    );
}

export function deactivate(): Thenable<void> | undefined {
    if (lspClient) {
        return lspClient.stop();
    }
    return undefined;
}
