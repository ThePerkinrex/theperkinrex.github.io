// Hero for /blog/timed-transfers-madrid/: the A-6 corridor as a schematic transit map. The rail
// line runs from Villalba (top left) down a 45° bend to Madrid (bottom right); grey feeder buses
// hook into its stations, and at the hub a bus (amber) waits for the train coming down the line.
// Render: typst compile --font-path static/typst-fonts --format svg static/hero-sources/timed-transfers-madrid.typ static/web-assets/images/timed-transfers-madrid.svg
#import "_common.typ": *
#show: hero.with(rgb("#2b6cb0"), rgb("#1a2a4f"))

#let accent = rgb("#fbbf24")
#let navy = rgb("#1a2f57")

// Geometry helpers.
#let f(l) = l / 1pt
#let unit(a, b) = {
  let (dx, dy) = (f(b.at(0) - a.at(0)), f(b.at(1) - a.at(1)))
  let n = calc.sqrt(dx * dx + dy * dy)
  (dx / n, dy / n, n)
}
#let lerp(a, b, t) = (a.at(0) + (b.at(0) - a.at(0)) * t, a.at(1) + (b.at(1) - a.at(1)) * t)
// The point a fraction t along a polyline (ignoring the rounded corners), with its segment.
#let along(pts, t) = {
  let lens = range(1, pts.len()).map(i => unit(pts.at(i - 1), pts.at(i)).at(2))
  let target = t * lens.sum()
  let acc = 0
  for i in range(lens.len()) {
    if acc + lens.at(i) >= target {
      return (lerp(pts.at(i), pts.at(i + 1), (target - acc) / lens.at(i)), pts.at(i), pts.at(i + 1))
    }
    acc += lens.at(i)
  }
  (pts.last(), pts.at(-2), pts.last())
}

// A polyline with its corners rounded to radius r.
#let route(pts, paint, w, r: 36pt) = {
  let segs = (curve.move(pts.first()),)
  for i in range(1, pts.len() - 1) {
    let (a, p, b) = (pts.at(i - 1), pts.at(i), pts.at(i + 1))
    let (ux, uy, n1) = unit(a, p)
    let (vx, vy, n2) = unit(p, b)
    let rr = calc.min(f(r), n1 / 2, n2 / 2) * 1pt
    segs.push(curve.line((p.at(0) - ux * rr, p.at(1) - uy * rr)))
    segs.push(curve.quad(p, (p.at(0) + vx * rr, p.at(1) + vy * rr)))
  }
  segs.push(curve.line(pts.last()))
  place(curve(stroke: (paint: paint, thickness: w, join: "round", cap: "round"), ..segs))
}

// A station tick at p: a short bar sticking out of segment a→b on `side`.
#let tick-at(p, a, b, paint, len: 14pt, w: 6pt, side: 1) = {
  let (ux, uy, _) = unit(a, b)
  let (nx, ny) = (-uy * side, ux * side)
  place(line(start: p, end: (p.at(0) + nx * len, p.at(1) + ny * len), stroke: (paint: paint, thickness: w, cap: "butt")))
}
#let tick(a, b, t, ..args) = tick-at(lerp(a, b, t), a, b, ..args)

#let ring(p, r: 11pt, w: 5pt) = place(dx: p.at(0) - r, dy: p.at(1) - r, circle(radius: r, fill: white, stroke: w + navy))
// An interchange: two rings joined by a capsule.
#let interchange(p, q, r: 13pt, w: 5pt) = {
  place(line(start: p, end: q, stroke: (paint: navy, thickness: 2 * r, cap: "round")))
  place(line(start: p, end: q, stroke: (paint: white, thickness: 2 * r - 2 * w, cap: "round")))
  ring(p, r: r, w: w)
  ring(q, r: r, w: w)
}

// Vehicle glyphs on a rounded tile centred on p.
#let tile(p, fill, body, s: 34pt) = place(dx: p.at(0) - s / 2, dy: p.at(1) - s / 2, box(
  width: s,
  height: s,
  radius: s / 4,
  fill: fill,
  stroke: 3pt + navy,
  body,
))
#let bus-glyph = {
  place(dx: 7pt, dy: 7pt, rect(width: 20pt, height: 17pt, radius: 3pt, fill: navy))
  place(dx: 10pt, dy: 10pt, rect(width: 14pt, height: 6pt, radius: 1pt, fill: white.transparentize(10%)))
  place(dx: 9pt, dy: 23pt, rect(width: 4pt, height: 4pt, fill: navy))
  place(dx: 21pt, dy: 23pt, rect(width: 4pt, height: 4pt, fill: navy))
}
#let train-glyph = {
  place(dx: 8pt, dy: 6pt, rect(width: 18pt, height: 18pt, radius: (top: 6pt, bottom: 2pt), fill: navy))
  place(dx: 11pt, dy: 9pt, rect(width: 12pt, height: 6pt, radius: 1pt, fill: white.transparentize(10%)))
  place(line(start: (10pt, 28pt), end: (24pt, 28pt), stroke: 2.5pt + navy))
}

// The network.
#let rail = ((96pt, 160pt), (300pt, 160pt), (510pt, 370pt), (936pt, 370pt))
#let hub = (405pt, 265pt)
#let hub-bus = (432pt, 238pt)
#let feeder-hub = (hub-bus, (555pt, 115pt), (880pt, 115pt))
#let feeders = (
  ((170pt, 160pt), (170pt, 290pt), (90pt, 370pt), (40pt, 370pt)),
  ((700pt, 370pt), (700pt, 280pt), (780pt, 200pt), (930pt, 200pt)),
)
// Intermediate stations: (segment start, segment end, fraction along it).
#let stations = (
  (rail.at(0), rail.at(1), 0.36),
  (rail.at(0), rail.at(1), 0.7),
  (rail.at(1), rail.at(2), 0.25),
  (rail.at(1), rail.at(2), 0.75),
  (rail.at(2), rail.at(3), 0.22),
  (rail.at(2), rail.at(3), 0.45),
  (rail.at(2), rail.at(3), 0.73),
)

// Grey feeders, each with an end bar.
#for pts in feeders {
  route(pts, ink(45%), 6pt, r: 24pt)
  let (a, b) = (pts.at(-2), pts.last())
  for side in (1, -1) { tick(a, b, 1.0, ink(45%), len: 10pt, w: 6pt, side: side) }
}

// The hub's feeder, with its stops.
#route(feeder-hub, accent, 9pt, r: 30pt)
#for t in (0.42, 0.62, 0.82) {
  let (p, a, b) = along(feeder-hub, t)
  tick-at(p, a, b, accent, len: 14pt, w: 6pt, side: -1)
}

// The rail line, its stations, the feeder interchanges and the termini.
#route(rail, white, 14pt, r: 50pt)
#for (a, b, t) in stations { tick(a, b, t, white, len: 16pt, w: 7pt) }
#ring(feeders.at(0).first())
#ring(feeders.at(1).first())
#ring(rail.first(), r: 13pt)
#ring(rail.last(), r: 13pt)

// The hub, pinging.
#for (i, r) in (34pt, 50pt).enumerate() {
  place(dx: hub.at(0) - r, dy: hub.at(1) - r, circle(radius: r, stroke: 3pt + accent.transparentize(35% + i * 30%)))
}
#interchange(hub, hub-bus)

// The train on its way down; the bus waiting for it.
#tile(lerp(rail.at(1), rail.at(2), 0.12), white, train-glyph)
#tile(along(feeder-hub, 0.2).at(0), accent, bus-glyph)
