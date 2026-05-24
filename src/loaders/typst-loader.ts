import type { Loader, LoaderContext } from "astro/loaders";
import { spawnSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { glob } from "node:fs/promises";
import path from "node:path";
import { z } from "astro/zod";
import type { SchemaContext } from "astro:content";
import { TYPST_ARGS } from "../lib/typst";
import { mkdirSync, rmSync } from "node:fs";

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
		pdfPath: z.string()
	});
export type Post = z.infer<ReturnType<typeof postSchema>>;

export function typstLoader(options: { postsDir: string }) {
	return {
		name: "typst-loader",
		// schema: postSchema,

		async load({ store, logger, parseData }: LoaderContext) {
			const public_base = path.join(process.cwd(), "public")
			const pdfDir = path.join("blog", "pdf");
			mkdirSync(path.join(public_base, pdfDir), { recursive: true });
			rmSync(path.join(public_base, pdfDir), {recursive: true});
			mkdirSync(path.join(public_base, pdfDir), { recursive: true });

			store.clear();

			const pattern = path.join(options.postsDir, "**/*.typ");

			for await (const file of glob(pattern)) {
				logger.info("Loading " + file);
				const id = path
					.relative(options.postsDir, file)
					.replace(/\.typ$/, "");

				let raw: Record<string, unknown>;
				try {
					const out = spawnSync(
						"typst",
						[
							"query",
							...TYPST_ARGS,
							file,
							"<post-meta>",
							"--field",
							"value",
						],
						{ encoding: "utf8" },
					);
					if(out.error) throw out.error
					// query returns a JSON array of all matches; take the first
					raw = JSON.parse(out.stdout)[0];
				} catch (e) {
					logger.warn(`Skipping ${file}: could not query metadata`);
					continue;
				}

				const slug = id.replace(/\//g, "-"); // flatten nested paths: a/b → a-b
				const pdfOut = path.join(pdfDir, `${slug}.pdf`);

				logger.info("Raw post data: " + JSON.stringify(raw));

				const data = await parseData<Record<string, unknown>>({ id, data: {...raw, pdfPath: '/' + pdfOut} });
				logger.info("Parsed data: " + JSON.stringify(data));

				if (data.draft && import.meta.env.PROD) continue;

				try {
					const out = spawnSync('typst', ['compile', ...TYPST_ARGS, file, path.join(public_base, pdfOut)]);
					if(out.error) throw out.error;
					logger.info('Built at ' + path.join(public_base, pdfOut))
				} catch (e) {
					logger.warn(`Could not compile PDF for ${file}`);
				}


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
