// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import starlightSidebarTopics from 'starlight-sidebar-topics';
import sidebar from './src/sidebar.json' with { type: 'json' };

// GitHub Pages: https://larrydewey.github.io/zyl/
export default defineConfig({
	site: 'https://larrydewey.github.io',
	base: '/zyl',
	integrations: [
		starlight({
			title: 'Zyl',
			description: 'Deterministic Power. Expressive Safety. A self-hosting Lisp systems language.',
			logo: { src: './src/assets/logo-mark.svg', alt: 'Zyl' },
			favicon: '/favicon.svg',
			social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/larrydewey/zyl' }],
			customCss: ['./src/styles/custom.css'],
			editLink: { baseUrl: 'https://github.com/larrydewey/zyl/edit/master/website/' },
			lastUpdated: true,
			plugins: [starlightSidebarTopics(sidebar)],
		}),
	],
});
