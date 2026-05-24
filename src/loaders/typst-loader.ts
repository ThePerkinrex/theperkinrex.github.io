import type { Loader, LoaderContext } from "astro/loaders";
import { execSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { glob } from "node:fs/promises";
import path from "node:path";
import { z } from "astro/zod";
import type { SchemaContext } from "astro:content";


export const postSchema = ({ image }: SchemaContext) =>
	z.object({
		title: z.string(),
		description: z.string(),
		// Transform string to Date object
		pubDate: z.coerce.date(),
		updatedDate: z.coerce.date().optional(),
		heroImage: z.optional(image()),
		tags: z.array(z.string()).default([]),
		draft: z.boolean().default(false),
	});
export type Post = z.infer<ReturnType<typeof postSchema>>;

export function typstLoader(options: { postsDir: string }) {
	return {
		name: "typst-loader",
		// schema: postSchema,

		async load({ store, logger, parseData }: LoaderContext) {
			store.clear();

			const pattern = path.join(options.postsDir, "**/*.typ");

			for await (const file of glob(pattern)) {
				const id = path
					.relative(options.postsDir, file)
					.replace(/\.typ$/, "");

				let raw: Record<string, unknown>;
				try {
					const json = execSync(
						`typst query "${file}" "<post-meta>" --field value`,
						{ encoding: "utf8" },
					);
					// query returns a JSON array of all matches; take the first
					raw = JSON.parse(json)[0];
				} catch (e) {
					logger.warn(`Skipping ${file}: could not query metadata`);
					continue;
				}

				logger.info('Raw post data: ' + JSON.stringify(raw))

				const data = await parseData({ id, data: raw });
				logger.info("Parsed data: " + JSON.stringify(data))

				if (data.draft && import.meta.env.PROD) continue;

				store.set({
					id,
					data,
					// Store the source path; we'll compile on demand
					filePath: file,
				});
			}
		},
	} satisfies Loader;
}
