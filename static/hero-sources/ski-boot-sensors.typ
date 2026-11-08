// Hero for /blog/ski-boot-sensors/: a skier carving down the slope, their S-shaped tracks behind
// them, and the boot sensors pinging.
// Render: typst compile --font-path static/typst-fonts --format svg static/hero-sources/ski-boot-sensors.typ static/web-assets/images/ski-boot-sensors.svg
// The skier is Font Awesome Free's `person-skiing` (solid; CC BY 4.0, https://fontawesome.com/license/free),
// recoloured white, its viewBox grown from 512 to 552 tall because the ski's underside reaches y ≈ 547 and the
// original clips it; the licence needs the credit drawn in the bottom-right corner.
#import "_common.typ": *
#show: hero.with(rgb("#4aa3df"), rgb("#1d3f7a"))



// The skier; positions below are fractions of the icon's box.
#let size = 280pt
#let (X, Y) = (640pt, 170pt)
#let at(fx, fy) = (X + fx * size, Y + fy * size)
#let tail = at(0.035, 0.535)

// Tracks: a pair of S-curves from the top left that settle into the skis' tail.
#let track(offset, paint) = {
  let (x0, y0) = (30pt, 70pt)
  let (x1, y1) = tail
  let n = 200
  let pts = range(0, n + 1).map(i => {
    let t = i / n
    let swing = 80pt * calc.sin(t * 3 * 2 * calc.pi) * (1 - t) * (0.5 + t)
    (x0 + (x1 - x0) * t + swing * 0.35, y0 + (y1 - y0) * t - swing + offset)
  })
  place(curve(stroke: (paint: paint, thickness: 3.5pt, join: "round", cap: "round"),
    curve.move(pts.first()), ..pts.slice(1).map(p => curve.line(p))))
}
#track(0pt, ink(40%))
#track(12pt, ink(60%))

#place(dx: X, dy: Y, image("skier-white.svg", width: size))

#place(bottom + right, dx: -16pt, dy: -12pt,
  text(size: 12pt, fill: ink(45%))[Skier icon: Font Awesome Free, CC BY 4.0])

// Sensor pings from the front of the boot, ahead of the skier.
#let (bx, by) = at(0.53, 0.71)
#for (i, r) in (30pt, 50pt, 70pt).map(r => r * (size / 360pt)).enumerate() {
  place(dx: bx, dy: by, curve(stroke: (paint: ink(10% + i * 25%), thickness: 4pt, cap: "round"),
    curve.move((r * calc.cos(-35deg), r * calc.sin(-35deg))),
    ..range(1, 21).map(k => { let a = -35deg + k * 3deg; curve.line((r * calc.cos(a), r * calc.sin(a))) })))
}
