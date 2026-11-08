// The downloadable PDF version of a blog post. It follows the web page's look (site/page.typ and
// site.css, light theme): hero image, centred title block, Atkinson Hyperlegible, logo colours.
// Components pick their paged rendering themselves (see site/components.typ).

#import "@tola/address:0.0.0": output-url, route-url
#import "@tola/code:0.0.0": code-themes
#import "@tola/document:0.0.0": current-document
#import "@tola/site:0.0.0": site
#import "components.typ": asset-source
#import "selection.typ": pdf-output
#import "theme.typ": body-font, mono-font, palette

#let logo = "/static/web-assets/images/logo.png"

#let format-date(d) = d.display("[month repr:short] [day padding:none], [year]")

/// An absolute URL for a site route, so links still work once the PDF is downloaded.
#let absolute(route) = if site.origin == none { route } else { route-url(route, origin: site.origin) }

#let pill(body, fill: palette.teal-soft, color: palette.heading) = box(
  inset: (x: 0.7em, y: 0.25em),
  outset: (y: 0.05em),
  radius: 999pt,
  fill: fill,
  text(size: 0.8em, fill: color, body),
)

#let draft-badge = box(
  inset: (x: 0.6em, y: 0.3em),
  radius: 3pt,
  fill: palette.draft-bg,
  text(size: 0.7em, weight: "bold", tracking: 0.05em, fill: palette.draft-text, upper[Draft]),
)

/// Styling for a post body on paper: the paged counterpart of site.css's prose rules.
#let print-rules(body) = context {
  let here-doc = current-document().location

  set text(font: body-font, size: 11pt, fill: palette.text)
  set par(leading: 0.75em, spacing: 1.3em)
  set list(indent: 0.6em)
  set enum(indent: 0.6em)

  // Headings: `=` is the web's <h2>; the scale follows site.css, a step smaller for paper.
  show heading: set text(fill: palette.heading, weight: "bold")
  show heading: set block(above: 1.6em, below: 0.8em)
  // Absolute sizes: `em` would compound with Typst's own heading sizes.
  show heading.where(level: 1): set text(size: 17pt)
  show heading.where(level: 2): set text(size: 14pt)
  show heading.where(level: 3): set text(size: 12pt)

  // Links: accent colour with a logo-blue underline; site routes become absolute URLs.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("/") {
      link(absolute(it.dest), it.body)
    } else { it }
  }
  show link: it => if type(it.dest) == str {
    text(fill: palette.accent, underline(stroke: 0.6pt + palette.logo-blue, offset: 2pt, it))
  } else { it }

  // Code, highlighted with the same theme as the light web page.
  set raw(theme: code-themes.github)
  show raw: set text(font: mono-font)
  show raw.where(block: false): it => box(
    fill: palette.code-bg,
    inset: (x: 3pt),
    outset: (y: 3pt),
    radius: 3pt,
    text(size: 0.9em, it),
  )
  show raw.where(block: true): it => block(
    width: 100%,
    fill: palette.code-bg,
    stroke: 0.75pt + palette.line,
    radius: 6pt,
    inset: (x: 1.2em, y: 1em),
    text(size: 0.85em, it),
  )

  show quote.where(block: true): it => block(
    inset: (left: 15pt, y: 2pt),
    stroke: (left: 3pt + palette.logo-blue),
    text(size: 1.15em, it.body),
  )

  // Tables: rules under each row, a teal one under the header.
  set table(
    stroke: (_, y) => (bottom: if y == 0 { 1.5pt + palette.logo-teal } else { 0.75pt + palette.line }),
    inset: (x: 0.6em, y: 0.5em),
    align: left,
  )
  show table.cell.where(y: 0): set text(fill: palette.heading, weight: "bold")

  // The table of contents only lists this document's headings, in a bordered box.
  set outline(target: selector(heading).within(here-doc), title: [Contents])
  show outline: it => block(
    width: 100%,
    inset: (x: 1.2em, y: 1em),
    radius: 6pt,
    stroke: 0.75pt + palette.line,
    {
      set text(size: 0.9em)
      show heading: set text(size: 12pt)
      show heading: set block(above: 0pt, below: 0.8em)
      it
    },
  )

  set footnote.entry(separator: line(length: 30%, stroke: 0.5pt + palette.line))
  show footnote.entry: set text(size: 0.85em)
  show bibliography: set text(size: 0.9em)
  show bibliography: it => {
    line(length: 100%, stroke: 0.75pt + palette.line)
    it
  }

  // Footnote numbers are counted across the whole build, so restart them for this document.
  counter(footnote).update(0)
  body
}

/// The running header (logo, site name, post title) and footer (URL, page count).
#let page-furniture(title, url) = (
  header: context if here().page() > 1 {
    set text(size: 8.5pt, fill: palette.muted)
    grid(
      columns: (auto, 1fr),
      align: horizon,
      gutter: 0.6em,
      box(clip: true, radius: 2pt, image(logo, height: 1.4em)),
      [#text(weight: "bold", fill: palette.heading, site.title) #h(0.4em) / #h(0.4em) #title],
    )
    v(-0.5em)
    line(length: 100%, stroke: 0.5pt + palette.line)
  },
  footer: context {
    set text(size: 8.5pt, fill: palette.muted)
    grid(
      columns: (1fr, auto),
      if url != none { link(url, url) }, [#counter(page).display() / #counter(page).final().first()],
    )
  },
  // The web header's teal top border, and the page's soft teal wash behind the first page.
  background: context {
    if here().page() == 1 {
      place(top, rect(width: 100%, height: 9cm, fill: gradient.linear(
        palette.teal-soft,
        white,
        angle: 90deg,
      )))
    }
    place(top, rect(width: 100%, height: 4pt, fill: palette.logo-teal))
  },
)

/// Declare the PDF of one blog post next to its page.
#let post-pdf(post) = {
  let meta = post.source.meta
  let url = if site.origin == none { none } else { output-url(post.output, origin: site.origin) }
  let authors = if meta.authors == none { () } else if type(meta.authors) == array { meta.authors } else {
    (meta.authors,)
  }
  let author-names = authors.map(a => if type(a) == str { a } else { a.name })

  document(
    pdf-output(post),
    format: "pdf",
    title: meta.title,
    description: meta.description,
    author: author-names,
    keywords: meta.tags,
  )[
    #set std.page(
      paper: "a4",
      margin: (x: 2.2cm, top: 2.4cm, bottom: 2.2cm),
      ..page-furniture(meta.title, url),
    )
    #set text(font: body-font, fill: palette.text, lang: site.language.lang)

    #if meta.hero != none {
      block(
        width: 100%,
        radius: 10pt,
        clip: true,
        image(asset-source(meta.hero), width: 100%, alt: ""),
      )
    }

    // The title block, centred like `.post .title`.
    #align(center, block(width: 100%, inset: (y: 1em), {
      set par(spacing: 0.6em)
      text(fill: palette.muted, format-date(meta.date))
      if meta.updated != none {
        parbreak()
        text(fill: palette.muted, style: "italic")[Last updated on #format-date(meta.updated)]
      }
      if meta.draft {
        parbreak()
        draft-badge
      }
      v(0.4em)
      block(text(size: 26pt, weight: "bold", fill: palette.heading, hyphenate: false, meta.title))
      if meta.tags.len() > 0 {
        v(0.2em)
        meta.tags.map(pill).join(h(0.4em))
      }
      v(0.6em)
      line(length: 100%, stroke: 0.75pt + palette.line)
    }))

    #print-rules(include post.source.file)
  ]
}
