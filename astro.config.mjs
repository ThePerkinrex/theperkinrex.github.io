// @ts-check

import mdx from "@astrojs/mdx";
import sitemap from "@astrojs/sitemap";
import { defineConfig, fontProviders } from "astro/config";

// https://astro.build/config
export default defineConfig({
	site: "https://example.com",
	integrations: [mdx(), sitemap()],
	fonts: [
		{
			provider: fontProviders.local(),
			name: "Atkinson",
			cssVariable: "--font-atkinson",
			fallbacks: ["sans-serif"],
			options: {
				variants: [
					{
						src: [
							"./src/assets/fonts/AtkinsonHyperlegible-Regular.ttf",
						],
						weight: 400,
						style: "normal",
						display: "swap",
					},
					{
						src: [
							"./src/assets/fonts/AtkinsonHyperlegible-Bold.ttf",
						],
						weight: 700,
						style: "normal",
						display: "swap",
					},
				],
			},
		},
		{
			provider: fontProviders.local(),
			name: "Atkinson Mono",
			cssVariable: "--font-atkinson-mono",
			fallbacks: ["monospace"],
			options: {
				variants: [
					{
						src: [
							"./src/assets/fonts/AtkinsonHyperlegibleMono-VariableFont_wght.ttf",
						],
						weight: "100 900",
						style: "normal",
						display: "swap",
					},
					{
						src: [
							"./src/assets/fonts/AtkinsonHyperlegibleMono-Italic-VariableFont_wght.ttf",
						],
						weight: "100 900",
						style: "italic",
						display: "swap",
					},
				],
			},
		},
	],
});
