// Hero for /blog/pi-deploy-agent/: the release as a parcel. A shipping label addressed to the Pi
// over the tailnet, a tamper seal (the HMAC) and a "no assembly required" stamp, because the Pi
// never compiles anything.
// Render: typst compile --font-path static/typst-fonts --format svg static/hero-sources/pi-deploy-agent.typ static/web-assets/images/pi-deploy-agent.svg
#import "_common.typ": *
#show: hero.with(rgb("#1f7a54"), rgb("#1e293b"))

#let mono = "Atkinson Hyperlegible Mono"
#let ink-dark = rgb("#1e293b")
#let card = rgb("#c9a26b") // cardboard
#let tape = rgb("#e8cf9f")
#let accent = rgb("#c2410c")

// Motion lines: it's travelling.
#for (i, y) in (150pt, 210pt, 270pt, 330pt).enumerate() {
  place(line(start: (60pt + i * 18pt, y), end: (200pt + i * 6pt, y), stroke: (paint: ink(55% + i * 8%), thickness: 6pt, cap: "round")))
}

// The parcel, tilted a little.
#place(dx: 250pt, dy: 55pt, rotate(-4deg, reflow: false, {
  place(rect(width: 560pt, height: 380pt, radius: 10pt, fill: card, stroke: 5pt + white))
  place(dx: 250pt, rect(width: 60pt, height: 380pt, fill: tape))

  // The label.
  place(dx: 40pt, dy: 40pt, {
    set text(fill: ink-dark)
    place(rect(width: 300pt, height: 300pt, radius: 6pt, fill: white))
    place(dx: 20pt, dy: 18pt, text(size: 14pt, weight: "bold", tracking: 1.5pt)[FROM])
    place(dx: 20pt, dy: 38pt, text(font: mono, size: 18pt)[ci runner, aarch64])
    place(dx: 20pt, dy: 70pt, line(length: 260pt, stroke: 2pt + ink-dark))
    place(dx: 20pt, dy: 84pt, text(size: 14pt, weight: "bold", tracking: 1.5pt)[TO])
    place(dx: 20pt, dy: 104pt, text(font: mono, size: 26pt, weight: "bold")[pi])
    place(dx: 20pt, dy: 138pt, text(font: mono, size: 18pt)[via the tailnet])
    place(dx: 20pt, dy: 170pt, line(length: 260pt, stroke: 2pt + ink-dark))
    place(dx: 20pt, dy: 184pt, text(size: 14pt, weight: "bold", tracking: 1.5pt)[CONTENTS])
    place(dx: 20pt, dy: 204pt, text(font: mono, size: 18pt)[e41d07.tar.zst])
    // Barcode.
    let widths = (3, 1, 2, 1, 1, 3, 2, 1, 3, 1, 1, 2, 1, 3, 1, 2, 2, 1, 1, 3, 1, 2, 1, 1, 3, 2, 1, 2, 1, 3)
    let x = 20pt
    for (i, w) in widths.enumerate() {
      if calc.even(i) { place(dx: x, dy: 240pt, rect(width: w * 2.6pt, height: 42pt, fill: ink-dark)) }
      x += w * 2.6pt + 1.6pt
    }
  })

  // The tamper seal.
  place(dx: 410pt, dy: 52pt, {
    place(circle(radius: 52pt, fill: accent, stroke: 4pt + white))
    place(box(width: 104pt, height: 104pt, align(center + horizon, text(fill: white, weight: "bold")[
      #text(size: 22pt)[HMAC] \
      #text(size: 13pt, tracking: 1pt)[SEALED]
    ])))
  })
}))

// The stamp, straight across, on top.
#place(dx: 620pt, dy: 300pt, rotate(-14deg, reflow: false, box(
  inset: (x: 18pt, y: 12pt),
  radius: 6pt,
  stroke: 5pt + white,
  text(size: 24pt, weight: "bold", tracking: 2pt, fill: white)[PREBUILT \ #text(size: 17pt, tracking: 1.5pt)[NO ASSEMBLY REQUIRED]],
)))
