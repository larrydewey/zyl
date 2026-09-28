// Code block themes in the brand palette (the token colors of site/index.html).
const rules = (c) => [
	{ scope: ['comment', 'punctuation.definition.comment'], settings: { foreground: c.com, fontStyle: 'italic' } },
	{ scope: ['keyword', 'storage.type', 'storage.modifier', 'keyword.control'], settings: { foreground: c.kw } },
	{ scope: ['entity.name.type', 'support.type', 'entity.other.inherited-class', 'variable.other.constant'], settings: { foreground: c.ctor } },
	{ scope: ['entity.name.function', 'support.function'], settings: { foreground: c.fn } },
	{ scope: ['string', 'punctuation.definition.string'], settings: { foreground: c.str } },
	{ scope: ['constant.numeric', 'constant.language', 'constant.character.escape'], settings: { foreground: c.num } },
	{ scope: ['constant.other.keyword', 'entity.name.namespace'], settings: { foreground: c.ctor, fontStyle: 'italic' } },
	{ scope: ['keyword.operator'], settings: { foreground: c.op } },
	{ scope: ['punctuation.section.parens', 'punctuation'], settings: { foreground: c.paren } },
];

const theme = (name, type, c) => ({
	name,
	type,
	colors: {
		'editor.background': c.bg,
		'editor.foreground': c.fg,
		'editor.selectionBackground': c.sel,
		'editorLineNumber.foreground': c.com,
	},
	settings: [{ settings: { foreground: c.fg, background: c.bg } }, ...rules(c)],
});

export const zylDark = theme('zyl-dark', 'dark', {
	bg: '#081020', fg: '#E4EFEE', sel: '#1E3450',
	kw: '#41E5B7', ctor: '#7FD3F0', fn: '#ADE8DE', str: '#E8C98A', num: '#F0A38A',
	com: '#5E7A86', op: '#8EA7AE', paren: '#3F6A86',
});

export const zylLight = theme('zyl-light', 'light', {
	bg: '#F2F7F6', fg: '#0A2540', sel: '#C9DCD8',
	kw: '#00857B', ctor: '#1F6FA8', fn: '#0A5A55', str: '#8A5A00', num: '#B04A2E',
	com: '#6B8590', op: '#4B6470', paren: '#7C9AAE',
});
