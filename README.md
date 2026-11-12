# theperkinrex.github.io

My personal site and blog, built with [Tola](https://tola.build) (v0.8.1) and [Typst](https://typst.app).
Pushing to `master` deploys it to GitHub Pages (`.github/workflows/github-pages.yml`).

## Working on it

```sh
tola dev      # serve at http://127.0.0.1:5277 and rebuild on save (drafts included)
tola check    # production build + link checks, without writing public/
tola build    # write the production site to public/
```

The build hooks (`scripts/*.sh`) need `sh` and `rsvg-convert` on your `PATH`. On Windows, add
`C:\Program Files\Git\bin` (Git for Windows' `sh`) to your `PATH` and `scoop install resvg`:
`og-images.sh` uses `resvg` when `rsvg-convert` is missing.

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
| `static/hero-sources/` | Typst sources for SVG post banners (not published); render with `typst compile --font-path static/typst-fonts --format svg <file>.typ static/web-assets/images/<file>.svg` |
| `static/og-images/` | link-preview PNGs (gitignored), rendered from every SVG in `static/web-assets/images/` by the `og-images` hook and served under `/og/`; pages without a hero use `logo-wide.png` |
| `static/favicon.ico`, `static/apple-touch-icon.png` | browser icons served at the site root; regenerate with `scripts/make-icons.sh` if `logo.svg` or `favicon.svg` changes |
| `scripts/og-images.sh` | before-build hook that renders the link-preview PNGs (needs `rsvg-convert`) |
| `scripts/make-icons.sh` | renders `favicon.ico` (16/32/48px) from the rounded `favicon.svg` and `apple-touch-icon.png` (180px, square — iOS rounds it) from `logo.svg` (needs `rsvg-convert` and ImageMagick) |
| `scripts/build-mode.sh` | before-build hook that tells Typst whether this is `tola dev` (so drafts render) and the current year |
| `scripts/typst-mark-font.py` | builds `static/web-assets/fonts/TypstMark.woff2`, the Typst wordmark as a font so `#typst` is real text on the web; rerun if the wordmark SVG changes (needs `fontTools` and `brotli`) |

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
