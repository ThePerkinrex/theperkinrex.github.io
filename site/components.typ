// Components posts can use: `#import "/site/components.typ": *`
// (admonitions, `asset-image`, `details` and `csv-table`).
//
// Every post is rendered twice: as an HTML page and as a downloadable PDF (`site/print.typ`).
// Each component therefore has two renderings and picks one with `by-target`; posts only call the
// component and never use `html.*` directly, which the PDF would silently drop.

#import "@tola/address:0.0.0": asset-url
#import "theme.typ": admonition-tints, palette

/// `html` when rendering a web page, `paged` when rendering the PDF.
#let by-target(html: none, paged: none) = context if target() == "html" { html } else { paged }

/// The source file behind a published `/assets/...` URL (the `[assets]` tree in tola.toml), for
/// renderings that read the file itself, such as `image()` in the PDF.
#let asset-source(url) = {
  assert(url.starts-with("/assets/"), message: "expected an `/assets/...` URL, got `" + url + "`")
  "/static/web-assets/" + url.slice("/assets/".len())
}

// Icons (24×24, Lucide-style strokes). A part is an SVG path string, a circle as
// `(cx:, cy:, r:)`, or (HTML only) ready-made content.

#let svg-attrs = (
  viewBox: "0 0 24 24",
  fill: "none",
  "stroke-width": "2",
  "stroke-linecap": "round",
  "stroke-linejoin": "round",
)

/// An inline HTML `<svg>` icon drawn with the current text colour.
#let icon(..parts) = html.elem(
  "svg",
  attrs: svg-attrs + (width: "20", height: "20", stroke: "currentColor", "aria-hidden": "true"),
  parts
    .pos()
    .map(part => if type(part) == str {
      html.elem("path", attrs: (d: part))
    } else if type(part) == dictionary {
      html.elem("circle", attrs: part.pairs().map(((k, v)) => (k, str(v))).to-dict())
    } else { part })
    .join(),
)

/// The same icon as an image for paged output, stroked in `color`.
#let icon-image(parts, color, height: 1em) = {
  let attrs = svg-attrs + (xmlns: "http://www.w3.org/2000/svg", stroke: color.to-hex())
  let body = parts
    .map(part => if type(part) == str {
      "<path d=\"" + part + "\"/>"
    } else {
      "<circle " + part.pairs().map(((k, v)) => k + "=\"" + str(v) + "\"").join(" ") + "/>"
    })
    .join()
  let open = "<svg " + attrs.pairs().map(((k, v)) => k + "=\"" + v + "\"").join(" ") + ">"
  box(baseline: 15%, image(bytes(open + body + "</svg>"), format: "svg", height: height))
}

#let circle = (cx: 12, cy: 12, r: 10)

#let admonition-kinds = (
  note: (title: "Note", icon: (circle, "M12 16v-4", "M12 8h.01")),
  tip: (
    title: "Tip",
    icon: (
      "M15 14c.2-1 .7-1.7 1.5-2.5 1-.9 1.5-2.2 1.5-3.5A6 6 0 0 0 6 8c0 1 .2 2.2 1.5 3.5.7.7 1.3 1.5 1.5 2.5",
      "M9 18h6",
      "M10 22h4",
    ),
  ),
  important: (title: "Important", icon: (circle, "M12 8v4", "M12 16h.01")),
  warning: (
    title: "Warning",
    icon: ("m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3", "M12 9v4", "M12 17h.01"),
  ),
  caution: (
    title: "Caution",
    icon: (
      "M15.312 2a2 2 0 0 1 1.414.586l4.688 4.688A2 2 0 0 1 22 8.688v6.624a2 2 0 0 1-.586 1.414l-4.688 4.688a2 2 0 0 1-1.414.586H8.688a2 2 0 0 1-1.414-.586l-4.688-4.688A2 2 0 0 1 2 15.312V8.688a2 2 0 0 1 .586-1.414l4.688-4.688A2 2 0 0 1 8.688 2z",
      "M12 8v4",
      "M12 16h.01",
    ),
  ),
)

/// A callout box. `kind` is one of note, tip, important, warning, caution.
#let admonition(kind, title: auto, body) = {
  assert(kind in admonition-kinds, message: "unknown admonition kind `" + kind + "`")
  let spec = admonition-kinds.at(kind)
  let title = if title == auto { spec.title } else { title }
  let tint = admonition-tints.at(kind)
  by-target(
    html: html.aside(class: "admonition " + kind)[
      #html.p(class: "admonition-title", {
        icon(..spec.icon)
        html.span(title)
      })
      #body
    ],
    paged: block(
      width: 100%,
      inset: (x: 1em, y: 0.75em),
      radius: (right: 6pt),
      fill: tint.transparentize(90%),
      stroke: (left: 3pt + tint),
      {
        block(below: 0.6em, sticky: true, text(fill: tint, weight: "bold")[#icon-image(spec.icon, tint) #h(
            0.3em,
          ) #title])
        body
      },
    ),
  )
}

#let note = admonition.with("note")
#let tip = admonition.with("tip")
#let important = admonition.with("important")
#let warning = admonition.with("warning")
#let caution = admonition.with("caution")

/// An image from `static/web-assets/` by its `/assets/...` URL. The web page loads the published
/// file; the PDF embeds it. `width`/`height` are CSS pixels.
#let asset-image(url, alt: none, width: none, height: none) = by-target(
  html: html.img(src: asset-url(url), alt: if alt == none { "" } else { alt }, width: width, height: height),
  paged: block(image(
    asset-source(url),
    alt: alt,
    width: if width == none { auto } else { width * 0.75pt },
    height: if height == none { auto } else { height * 0.75pt },
  )),
)

/// A collapsible section. On paper it is always open, under its summary.
#let details(summary, body) = by-target(
  html: html.details[
    #html.summary(summary)
    #body
  ],
  paged: block(
    width: 100%,
    inset: (left: 1em),
    stroke: (left: 1pt + palette.line),
    {
      block(below: 0.6em, sticky: true, text(fill: palette.accent)[▾ #summary])
      body
    },
  ),
)

/// A table from parsed CSV rows whose first row is the header: `#csv-table(csv("data.csv"))`.
/// Call `csv` in the post itself, so the path resolves next to the post.
#let csv-table(rows) = {
  let (header, ..body) = rows
  table(
    columns: header.len(),
    table.header(..header.map(cell => [#cell])),
    ..body.flatten().map(cell => [#cell]),
  )
}
