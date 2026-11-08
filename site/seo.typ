#import "@tola/site:0.0.0": site
#import "@tola/web:0.0.0": canonical, feed, head-metadata, open-graph, plain-text, sitemap
#import "@tola/address:0.0.0": output-url

/// The head entries one document carries: charset, viewport, title, description, plus canonical
/// and Open Graph entries for documents with an address.
///
/// - title (content | string): the document's title.
/// - description (none | content | string): the document's description.
/// - page (none | dictionary): the `(source:, output:)` record, when the document has a source.
/// -> array
#let head-entries(title, description: none, page: none) = {
  let entries = head-metadata(site, title: title, description: description)
  if page != none and site.origin != none {
    let url = output-url(page.output, origin: site.origin)
    let meta = page.source.meta
    let plain-title = if meta.title == none { "" } else { plain-text(meta.title) }
    // Link previews (Open Graph) don't accept SVG, so SVG heroes fall back to the logo there.
    let image = if meta.hero != none and not meta.hero.ends-with(".svg") { site.origin + meta.hero } else {
      site.origin + "/assets/images/logo.png"
    }
    entries += canonical(url)
    if plain-title != "" {
      entries += open-graph(
        title: plain-title,
        url: url,
        description: if meta.description == none { none } else { plain-text(meta.description) },
        site-name: site.title,
        locale: site.language.tag,
        images: ((url: image, alt: plain-title),),
      )
    }
  }
  entries
}

#let rfc3339(d) = d.display("[year]-[month]-[day]") + "T00:00:00Z"

/// Declare the RSS feed for `posts` (newest first). Drafts never reach the feed.
#let feed-output(output, posts) = {
  if site.origin == none or site.title == "" { return }
  feed(
    output: output,
    entries: posts
      .filter(post => post.source.meta.feed and not post.source.meta.draft)
      .map(post => (
        target: post.output,
        published: rfc3339(post.source.meta.date),
        updated: if post.source.meta.updated == none { none } else { rfc3339(post.source.meta.updated) },
        summary: post.source.meta.description,
        content: (document: post.output, id: "post-body"),
      )),
  )
}

/// Declare the sitemap: every non-draft page plus the generated listing documents.
#let sitemap-output(output, pages, extra: ()) = {
  if site.origin == none { return }
  sitemap(
    output: output,
    targets: pages
      .filter(page => page.source.meta.sitemap and not page.source.meta.draft)
      .map(page => {
        let m = page.source.meta
        let last = if m.updated != none { m.updated } else { m.date }
        (
          target: page.output,
          lastmod: if last == none { none } else { last.display("[year]-[month]-[day]") },
        )
      })
      + extra.map(output => (target: output)),
  )
}
