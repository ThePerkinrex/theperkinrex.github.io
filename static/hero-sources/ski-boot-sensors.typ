// Hero for /blog/ski-boot-sensors/: one run's GPS fixes zig-zagging down a contour map of the slope,
// the finish pinging, and a card with the run's made-up stats and edge angle per turn from the boots.
// Render: typst compile --font-path static/typst-fonts --format svg static/hero-sources/ski-boot-sensors.typ static/web-assets/images/ski-boot-sensors.svg
#import "_common.typ": *
#show: hero.with(rgb("#4aa3df"), rgb("#1d3f7a"))
#let navy = rgb("#1d3f7a")

// Contour lines: wavy, running across the fall line, every fifth one heavier.
#for k in range(-8, 44) {
  let major = calc.rem(k + 20, 5) == 0
  let pts = range(0, 121).map(i => {
    let x = -20pt + i * 9pt
    let u = x / 1pt
    (x, k * 24pt + 26pt * calc.sin(u / 170 + k * 0.22) + 12pt * calc.sin(u / 61 - k * 0.5) - x * 0.42 + 300pt)
  })
  place(curve(
    stroke: (paint: ink(if major { 72% } else { 87% }), thickness: if major { 2.2pt } else { 1.4pt }, join: "round"),
    curve.move(pts.first()),
    ..pts.slice(1).map(p => curve.line(p)),
  ))
}

// The run: from the start down to the finish, swinging across the fall line.
#let (sx, sy) = (110pt, 70pt)
#let (ex, ey) = (600pt, 420pt)
#let (dx, dy) = ((ex - sx) / 1pt, (ey - sy) / 1pt)
#let len = calc.sqrt(dx * dx + dy * dy)
#let path(t) = {
  let swing = 70pt * calc.sin(t * 4.5 * 2 * calc.pi) * (0.6 + 0.4 * t)
  (sx + (ex - sx) * t - swing * dy / len, sy + (ey - sy) * t + swing * dx / len)
}
#let fine = range(0, 301).map(i => path(i / 300))
#place(curve(
  stroke: (paint: ink(50%), thickness: 3pt, join: "round", cap: "round"),
  curve.move(fine.first()),
  ..fine.slice(1).map(p => curve.line(p)),
))
// One dot per GPS fix.
#for i in range(0, 61) {
  let (x, y) = path(i / 60)
  place(dx: x - 4pt, dy: y - 4pt, circle(radius: 4pt, fill: white))
}

// Start, and the finish pinging.
#place(dx: sx - 9pt, dy: sy - 9pt, rect(width: 18pt, height: 18pt, radius: 3pt, fill: white))
#place(dx: ex - 9pt, dy: ey - 9pt, circle(radius: 9pt, fill: white))
#for (i, r) in (20pt, 32pt, 44pt).enumerate() {
  place(dx: ex - r, dy: ey - r, circle(radius: r, stroke: 3pt + ink(20% + i * 25%)))
}

// The run's card, with the edge angle of each turn; the steepest one picked out.
#place(dx: 700pt, dy: 140pt, {
  set text(fill: navy)
  place(rect(width: 260pt, height: 196pt, radius: 14pt, fill: white))
  place(dx: 20pt, dy: 16pt, text(size: 16pt, fill: navy.transparentize(30%))[Run 7 · 1.4 km · 2:41])
  place(dx: 20pt, dy: 38pt, text(size: 24pt, weight: "bold")[9 turns])
  place(dx: 128pt, dy: 46pt, text(size: 14pt, fill: navy.transparentize(25%))[edge angle per turn])
  let angles = (31, 38, 44, 47, 52, 49, 41, 36, 45)
  let top = calc.max(..angles)
  for (j, a) in angles.enumerate() {
    let h = 70pt * a / 55
    place(dx: 20pt + j * 25pt, dy: 172pt - h, rect(
      width: 17pt,
      height: h,
      radius: 3pt,
      fill: if a == top { navy } else { navy.transparentize(55%) },
    ))
  }
})
