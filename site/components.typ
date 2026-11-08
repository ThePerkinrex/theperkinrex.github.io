// Components posts can use: `#import "/site/components.typ": *`
// (admonitions, `asset-image`, `details`, `csv-table`, `code` and `kbd`).
//
// Every post is rendered twice: as an HTML page and as a downloadable PDF (`site/print.typ`).
// Each component therefore has two renderings and picks one with `by-target`; posts only call the
// component and never use `html.*` directly, which the PDF would silently drop.

#import "@tola/address:0.0.0": asset-url
#import "@preview/keyle:0.4.0"
#import "theme.typ": admonition-tints, mono-font, palette

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
    icon: (
      "m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3",
      "M12 9v4",
      "M12 17h.01",
    ),
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
        block(below: 0.6em, sticky: true, text(fill: tint, weight: "bold")[#icon-image(
            spec.icon,
            tint,
          ) #h(
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
  html: html.img(
    src: asset-url(url),
    alt: if alt == none { "" } else { alt },
    width: width,
    height: height,
  ),
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

// Code blocks are line-numbered by default (the `raw` rules in page.typ and print.typ read these
// options). `code` changes the options for the blocks in its body only.

#let code-defaults = (numbers: true, start: 1)
#let code-options = state("code-options", code-defaults)

/// Line-numbering options for the code blocks in `body`:
/// `#code(numbers: false)[```sh ...```]` or `#code(start: 42)[```rust ...```]`.
#let code(numbers: code-defaults.numbers, start: code-defaults.start, body) = {
  assert(type(numbers) == bool, message: "`numbers` must be true or false")
  assert(type(start) == int, message: "`start` must be an integer, got " + repr(start))
  code-options.update((numbers: numbers, start: start))
  body
  code-options.update(code-defaults)
}

/// The number shown for one `raw.line` under `options`.
#let line-number(line, options) = line.number + options.start - 1

/// How many digits the widest line number of a code block has, to size the number column.
#let line-number-digits(block, options) = calc.max(
  str(block.lines.len() + options.start - 1).len(),
  str(options.start).len(),
)

/// Keys and shortcuts, via the keyle package: `#kbd("Ctrl+Shift+P")`, `#kbd("Ctrl", "K")`,
/// `#kbd("cmd", "Q")` (aliases such as cmd, up, enter become glyphs). The web page gets semantic
/// `<kbd>` elements, styled in site.css; the PDF gets keycaps in the site's colours.
#let kbd = keyle.config(
  html: "kbd",
  theme: keyle.themes.standard.with(
    fill: palette.code-bg,
    stroke: palette.line.darken(25%) + 0.6pt,
    shadow: palette.line.darken(25%),
    text-args: (fill: palette.text, font: mono-font, size: 0.85em),
  ),
)

// Marks: `#latex` and `#typst` set the names the way the projects themselves do, in running text.

/// The LaTeX logo, built as `\LaTeX` builds it, in Computer Modern (here New Computer Modern, which
/// Typst embeds): a small raised A tucked under the T, and a lowered E. It follows the surrounding
/// weight. The offsets are LaTeX's own; site.css repeats them for HTML (`.latex-mark`), with a
/// five-letter subset of the font (`fonts/LaTeXMark-*.woff2`).
#let latex = by-target(
  html: html.elem("span", attrs: (
    class: "latex-mark",
    role: "img",
    aria-label: "LaTeX",
  ))[L#html.span(class: "a")[A]T#html.span(class: "e")[E]X],
  paged: box(text(font: "New Computer Modern")[L#h(-0.36em)#box(move(
      dy: -0.2em,
      text(size: 0.7em)[A],
    ))#h(-0.15em)T#h(-0.1667em)#box(move(dy: 0.215em)[E])#h(-0.125em)X]),
)

/// The official Typst wordmark's outlines (the hero art's copy), drawn in the current text colour.
/// Its viewBox is 91×35 with the baseline 24.41 units down and an x-height of about 20 units.
#let typst-wordmark-paths = (
  read("/static/hero-sources/typst-wordmark-white.svg")
    .matches(regex("\\bd=\"([^\"]+)\""))
    .map(m => m.captures.first())
)

/// The Typst wordmark, sized so its x-height matches the body font's and its baseline sits on the
/// line's. The HTML rendering is sized in site.css (`.typst-mark`).
#let typst = by-target(
  // The <span> keeps the <svg> inline: on its own Typst treats it as a block and ends the paragraph.
  html: html.elem("span", attrs: (class: "typst-mark", role: "img", aria-label: "Typst"), html.elem(
    "svg",
    attrs: (viewBox: "0 0 91 35", fill: "currentColor", "aria-hidden": "true"),
    typst-wordmark-paths.map(d => html.elem("path", attrs: (d: d))).join(),
  )),
  paged: context {
    let fill = if type(text.fill) == color { text.fill } else { black }
    let body = typst-wordmark-paths.map(d => "<path d=\"" + d + "\"/>").join()
    let svg = (
      "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 91 35\" fill=\""
        + fill.to-hex()
        + "\">"
        + body
        + "</svg>"
    )
    // 10.59 of the 35 units hang below the baseline.
    box(baseline: 30.26%, image(bytes(svg), format: "svg", height: 0.87em, alt: "Typst"))
  },
)
