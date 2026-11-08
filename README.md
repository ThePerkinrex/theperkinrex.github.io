# theperkinrex.github.io

My personal site and blog, built with [Tola](https://tola.build) (v0.8.1) and [Typst](https://typst.app).
Pushing to `master` deploys it to GitHub Pages (`.github/workflows/github-pages.yml`).

## Working on it

```sh
tola dev      # serve at http://127.0.0.1:5277 and rebuild on save (drafts included)
tola check    # production build + link checks, without writing public/
tola build    # write the production site to public/
```

### Editor

Use the [Tola VS Code extension](https://marketplace.visualstudio.com/items?itemName=tola.tola)
(`tola.tola`, recommended in `.vscode/extensions.json`) and disable Tinymist for this workspace.
Tinymist cannot resolve the `@tola/*` packages: they import a module only Tola provides at compile
time. The extension needs `tola` on your `PATH` (or `tola.serverPath` set).

## Layout

| Path | What it is |
| --- | --- |
| `content/index.typ`, `content/about.typ` | the home and about pages |
| `content/blog/*.typ` | blog posts; `content/blog/foo.typ` (or `content/blog/foo/index.typ`, with data files beside it) is served at `/blog/foo/` |
| `content/blog/example-post/` | a draft showing every feature a post can use (TOC, admonitions, code, maths, footnotes, citations, CSV tables); copy it to start a new post |
| `site.typ` | the root program: selects pages, renders them, and emits the blog index, 404, feed and sitemap |
| `site/` | templates: `layout.typ` (shell, header, footer), `page.typ` (home/post/page, footnotes, outline scoping), `components.typ` (admonitions, `csv-table`), `listing.typ` (blog index), `schema.typ` (allowed metadata fields) |
| `static/web-assets/` | CSS, fonts, images and `scripts/site.js` (theme toggle, sticky-header title), served under `/assets/` |
| `static/hero-sources/` | Typst sources for SVG post banners (not published); render with `typst compile --format svg <file>.typ static/web-assets/images/<file>.svg` |
| `scripts/build-mode.sh` | before-build hook that tells Typst whether this is `tola dev` (so drafts render) and the current year |

## Posts

Each post declares its metadata with `tola-meta` (fields are listed in `site/schema.typ`):

```typst
#import "@tola/source:0.0.0": tola-meta

#tola-meta((
  title: "My post",
  description: "One line shown in lists and link previews.",
  date: "2026-11-08",
  tags: ("rust",),
  draft: true, // only visible under `tola dev`
))
```

Drafts show up (with a badge) when running `tola dev`, and are left out of `tola build`, the RSS feed
and the sitemap.
