#import "@tola/address:0.0.0": join-route, output-of, slugify
#import "@tola/site:0.0.0": site
#import "@tola/source:0.0.0": parse-sources
#import "schema.typ": page-schema

/// The route one source publishes at: its `permalink`, or the route its file layout gives it.
#let source-route(source) = {
  if source.meta.permalink == none {
    join-route(source.route-segments.map(segment => slugify(segment, language: site.language.lang)))
  } else {
    source.meta.permalink
  }
}

/// Whether a source is a blog post: anything under `content/blog/`.
#let is-post(source) = source.id.starts-with("blog/")

/// `(dev: bool, year: int)`, written by the `scripts/build-mode.sh` hook before each build.
#let build-info = json("build-mode.json")
/// Whether this is a `tola dev` build.
#let dev-mode = build-info.dev

/// Select the sources to publish, each paired with the output file its route names. Drafts are
/// rendered under `tola dev` (marked as drafts) and dropped from production builds.
#let select-pages(sources) = {
  parse-sources(sources, page-schema)
    .filter(source => dev-mode or not source.meta.draft)
    .map(source => (
      source: source,
      output: output-of(source-route(source)),
    ))
}

/// The blog posts among `pages`, newest first. Every post must set a `date`.
#let select-posts(pages) = {
  let posts = pages.filter(page => is-post(page.source))
  for post in posts {
    assert(
      post.source.meta.date != none,
      message: "blog post `" + post.source.id + "` needs a `date` in its tola-meta",
    )
  }
  posts.sorted(key: post => (post.source.meta.date, post.source.id)).rev()
}
