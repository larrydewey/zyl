// Expressive Code options (code blocks and <Code>): Zyl grammar, brand themes and frames.
import zylGrammar from '../editors/vscode/syntaxes/zyl.tmLanguage.json' with { type: 'json' };
import { zylDark, zylLight } from './src/code-themes.mjs';

export default {
	themes: [zylDark, zylLight],
	shiki: { langs: [{ ...zylGrammar, name: 'zyl', aliases: ['lisp'] }] },
	styleOverrides: {
		borderRadius: '0.5rem',
		codeFontFamily: "'JetBrains Mono', ui-monospace, monospace",
		borderColor: ({ theme }) => (theme.type === 'dark' ? '#1E3450' : '#C9DCD8'),
		frames: {
			editorTabBarBackground: ({ theme }) => (theme.type === 'dark' ? '#0E1B2E' : '#E3EFEC'),
			editorActiveTabBackground: ({ theme }) => (theme.type === 'dark' ? '#081020' : '#F2F7F6'),
			editorActiveTabIndicatorTopColor: ({ theme }) => (theme.type === 'dark' ? '#41E5B7' : '#00857B'),
			editorActiveTabIndicatorBottomColor: 'transparent',
			terminalTitlebarBackground: ({ theme }) => (theme.type === 'dark' ? '#0E1B2E' : '#E3EFEC'),
			terminalBackground: ({ theme }) => (theme.type === 'dark' ? '#081020' : '#F2F7F6'),
		},
	},
};
