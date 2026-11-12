// Hero for /blog/fuel-price-tracker/: every station in mainland Spain as a dot, sized and brightened
// by a made-up price (cheaper is bigger and brighter), with "your" station pinging because it just
// got cheaper.
// Render: typst compile --font-path static/typst-fonts --format svg static/hero-sources/fuel-price-tracker.typ static/web-assets/images/fuel-price-tracker.svg
#import "_common.typ": *
#show: hero.with(rgb("#f59e0b"), rgb("#b42318"))

// Mainland Spain, as (lon, lat), clockwise from Cape Finisterre. Coarse on purpose.
#let outline = (
  (-9.3, 42.9), (-8.4, 43.4), (-7.7, 43.75), (-7.0, 43.55), (-5.7, 43.6), (-3.8, 43.5),
  (-2.9, 43.42), (-1.8, 43.38), (-1.4, 43.05), (0.0, 42.7), (0.7, 42.85), (1.4, 42.5),
  (2.2, 42.43), (3.3, 42.3), (3.2, 41.9), (2.2, 41.4), (1.0, 41.05), (0.9, 40.7), (0.0, 40.0),
  (-0.3, 39.45), (0.2, 38.75), (-0.5, 38.35), (-0.7, 37.9), (-1.0, 37.6), (-2.2, 36.73),
  (-2.9, 36.75), (-4.4, 36.7), (-5.0, 36.45), (-5.6, 36.0), (-6.3, 36.5), (-6.4, 36.8),
  (-6.95, 37.2), (-7.4, 37.2), (-7.5, 37.6), (-7.0, 38.0), (-7.3, 38.4), (-7.0, 38.9),
  (-7.4, 39.5), (-7.0, 39.7), (-6.9, 40.25), (-6.8, 40.9), (-6.2, 41.6), (-6.6, 41.95),
  (-7.2, 41.9), (-8.1, 41.85), (-8.87, 41.87), (-8.75, 42.2), (-9.0, 42.5),
)
#let k = 58pt // per degree of latitude
#let (lon0, lat0) = (-9.4, 43.9)
#let (ox, oy) = (250pt, 28pt)
#let proj((lon, lat)) = (ox + (lon - lon0) * k * 0.766, oy + (lat0 - lat) * k)
#let poly = outline.map(proj)

#let inside((x, y)) = {
  let c = false
  let n = poly.len()
  for i in range(n) {
    let (xi, yi) = poly.at(i)
    let (xj, yj) = poly.at(calc.rem(i + n - 1, n))
    if (yi > y) != (yj > y) and x < (xj - xi) * ((y - yi) / (yj - yi)) + xi { c = not c }
  }
  c
}

// A made-up price field in [0, 1]: a smooth regional trend plus per-station noise.
#let hash(i, j) = calc.fract(calc.abs(calc.sin(i * 12.9898 + j * 78.233)) * 43758.5453)
#let field(x, y, i, j) = {
  let u = (x - ox) / 1pt / 100
  let v = (y - oy) / 1pt / 100
  let trend = 0.5 + 0.28 * calc.sin(u * 1.1 + 0.6) * calc.cos(v * 0.9 - 0.4) - 0.12 * calc.cos(u * 0.5 + v)
  calc.clamp(trend + 0.35 * (hash(i, j) - 0.5), 0, 1)
}

#let step = 8.5pt
#for row in range(0, 64) {
  for col in range(0, 72) {
    let x = ox + col * step + calc.rem(row, 2) * step / 2
    let y = oy + row * step * 0.87
    if inside((x, y)) {
      let p = field(x, y, row, col)
      let r = 0.9pt + 2.6pt * (1 - p)
      place(dx: x - r, dy: y - r, circle(radius: r, fill: ink(15% + 60% * p)))
    }
  }
}

// Your station, somewhere near Madrid, pinging.
#let (sx, sy) = proj((-3.75, 40.3))
#place(dx: sx - 8pt, dy: sy - 8pt, circle(radius: 8pt, fill: white))
#for (i, r) in (18pt, 30pt, 42pt).enumerate() {
  place(dx: sx - r, dy: sy - r, circle(radius: r, stroke: 3pt + ink(20% + i * 25%)))
}

// The notification, out over the Mediterranean.
#let (nx, ny) = (740pt, sy - 110pt)
#place(dx: nx, dy: ny, {
  place(rect(width: 196pt, height: 64pt, radius: 14pt, fill: white))
  place(dx: 16pt, dy: 12pt, text(size: 16pt, fill: rgb("#b42318").transparentize(30%))[Your station])
  place(dx: 16pt, dy: 32pt, text(size: 22pt, weight: "bold", fill: rgb("#b42318"))[−4 cts · 1,489])
})
#place(line(start: (sx + 12pt, sy - 10pt), end: (nx, ny + 40pt), stroke: 3pt + white))

// Legend, in the Atlantic.
#place(dx: 56pt, dy: 392pt, {
  set text(size: 17pt, fill: ink(20%))
  place(dy: 0pt)[cheap]
  for (i, p) in (0, 0.25, 0.5, 0.75, 1).enumerate() {
    let r = 0.9pt + 2.6pt * (1 - p)
    place(dx: 64pt + i * 16pt - r, dy: 10pt - r, circle(radius: r, fill: ink(15% + 60% * p)))
  }
  place(dx: 144pt, dy: 0pt)[dear]
  place(dy: 34pt, text(size: 15pt, fill: ink(40%))[≈ 12 000 stations, every day])
})
