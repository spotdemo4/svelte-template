import type { Config } from "prettier";

const config: Config = {
	useTabs: true,
	printWidth: 100,
	plugins: [
		"prettier-plugin-svelte",
		"prettier-plugin-tailwindcss",
		"@ianvs/prettier-plugin-sort-imports",
	],
	overrides: [
		{
			files: "*.svelte",
			options: {
				parser: "svelte",
			},
		},
	],
	tailwindStylesheet: "./src/app.css",
};

export default config;
