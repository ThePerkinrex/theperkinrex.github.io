// Hero for /blog/switching-to-typst/. Render with:
//   typst compile --format svg static/hero-sources/switching-to-typst.typ static/web-assets/images/switching-to-typst.svg
// (Kept outside content/, where any .typ file would become a page, and outside web-assets/, which
// is published.) The Typst wordmark is the official one from typst.app, recoloured white.

#let W = 1020pt
#let H = 510pt
#let baseline = 280pt
#let gap = 72pt

#set page(width: W, height: H, margin: 0pt, fill: gradient.linear(
  rgb("#239dad"),
  rgb("#1c4e73"),
  angle: 25deg,
))
#set text(fill: white, top-edge: "baseline", bottom-edge: "baseline")

// A faint dot grid.
#place(rect(width: W, height: H, fill: tiling(
  size: (24pt, 24pt),
  place(dx: 12pt - 1.6pt, dy: 12pt - 1.6pt, circle(radius: 1.6pt, fill: white.transparentize(88%))),
)))

// 1. The word processor: an unbranded formatting toolbar.
#let toolbar(ink) = {
  set text(font: "DejaVu Sans", size: 30pt, fill: ink)
  let align-icon(widths) = box(baseline: -2pt, stack(
    spacing: 5pt,
    ..widths.map(w => line(length: w, stroke: 3pt + ink)),
  ))
  box(
    baseline: 0pt,
    inset: (x: 20pt, top: 15pt, bottom: 18pt),
    radius: 12pt,
    fill: white.transparentize(88%),
    stroke: 1.5pt + white.transparentize(70%),
    {
      text(weight: "bold")[B]
      h(18pt)
      text(style: "oblique")[I]
      h(18pt)
      underline(offset: 4pt, stroke: 2.5pt)[U]
      h(20pt)
      box(baseline: 6pt, line(angle: 90deg, length: 34pt, stroke: 1.5pt + ink))
      h(20pt)
      align-icon((28pt, 18pt, 28pt, 14pt))
    },
  )
}

// 2. LaTeX, in its own typeface and with its own kerning.
#let latex(ink) = {
  set text(font: "New Computer Modern", size: 88pt, fill: ink)
  [L#h(-0.36em)#box(move(dy: -0.21em, text(size: 0.7em)[A]))#h(-0.15em)T#h(-0.1667em)#box(move(dy: 0.2155em)[E])#h(-0.125em)X]
}

// 3. Typst: the wordmark's baseline sits 24.41 of its 35 units down.
#let typst-h = 300pt * 35 / 91
#let typst-logo = box(
  baseline: typst-h * (35 - 24.41) / 35,
  image("typst-wordmark-white.svg", width: 300pt),
)

// The row's top is the wordmark's ascender, so shift up by that to land every baseline on the rule.
#let typst-ascent = typst-h * 24.41 / 35

// Later stages are brighter: the eye travels left to right without an arrow.
#place(top + center, dy: baseline - typst-ascent, {
  toolbar(white.transparentize(50%))
  h(gap)
  latex(white.transparentize(25%))
  h(gap)
  typst-logo
})
