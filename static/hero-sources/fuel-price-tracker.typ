// Hero for /blog/fuel-price-tracker/: every station in mainland Spain binned into a dot grid, sized
// and brightened by the median gasolina 95 price in that dot (cheaper is bigger and brighter), with
// "your" station pinging because it just got cheaper. Prices are real, from fuel_prices.json, which
// summarize_fuel_prices.py builds from a full (unversioned) station dump.
// Render: typst compile --font-path static/typst-fonts --format svg static/hero-sources/fuel-price-tracker.typ static/web-assets/images/fuel-price-tracker.svg
#import "_common.typ": *
#show: hero.with(rgb("#f59e0b"), rgb("#b42318"))

#let data = json("fuel_prices.json")
#let g = data.grid

#let k = 58pt // per degree of latitude
#let (lon0, lat0) = (g.lon0, g.lat0)
#let (ox, oy) = (250pt, 28pt)
#let proj((lon, lat)) = (ox + (lon - lon0) * k * 0.766, oy + (lat0 - lat) * k)

// Map prices to [0, 1] over the 5th–95th percentile of the dots, so a few outliers don't wash it out.
#let prices = data.cells.map(c => c.at(2)).sorted()
#let lo = prices.at(int(prices.len() * 0.05))
#let hi = prices.at(int(prices.len() * 0.95))
#let norm(price) = calc.clamp((price - lo) / (hi - lo), 0, 1)
#let euros(price) = {
  let s = str(calc.round(price * 1000) / 1000).replace(".", ",")
  s + "0" * (5 - s.len())
}

// Mainland Spain, as (lon, lat), clockwise from Cape Finisterre. Coarse on purpose: only used to
// fill the grid with faint base dots where no station falls.
#let outline = (
  (-9.3, 42.9),
  (-8.4, 43.4),
  (-7.7, 43.75),
  (-7.0, 43.55),
  (-5.7, 43.6),
  (-3.8, 43.5),
  (-2.9, 43.42),
  (-1.8, 43.38),
  (-1.4, 43.05),
  (0.0, 42.7),
  (0.7, 42.85),
  (1.4, 42.5),
  (2.2, 42.43),
  (3.3, 42.3),
  (3.2, 41.9),
  (2.2, 41.4),
  (1.0, 41.05),
  (0.9, 40.7),
  (0.0, 40.0),
  (-0.3, 39.45),
  (0.2, 38.75),
  (-0.5, 38.35),
  (-0.7, 37.9),
  (-1.0, 37.6),
  (-2.2, 36.73),
  (-2.9, 36.75),
  (-4.4, 36.7),
  (-5.0, 36.45),
  (-5.6, 36.0),
  (-6.3, 36.5),
  (-6.4, 36.8),
  (-6.95, 37.2),
  (-7.4, 37.2),
  (-7.5, 37.6),
  (-7.0, 38.0),
  (-7.3, 38.4),
  (-7.0, 38.9),
  (-7.4, 39.5),
  (-7.0, 39.7),
  (-6.9, 40.25),
  (-6.8, 40.9),
  (-6.2, 41.6),
  (-6.6, 41.95),
  (-7.2, 41.9),
  (-8.1, 41.85),
  (-8.87, 41.87),
  (-8.75, 42.2),
  (-9.0, 42.5),
)
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

#let cell-xy(row, col) = proj((lon0 + (col + calc.rem(row, 2) / 2) * g.dlon, lat0 - row * g.dlat))
#let has-data = data.cells.map(c => str(c.at(0)) + "," + str(c.at(1)))
#for row in range(0, 64) {
  for col in range(0, 72) {
    let (x, y) = cell-xy(row, col)
    if inside((x, y)) and (str(row) + "," + str(col)) not in has-data {
      place(dx: x - 0.9pt, dy: y - 0.9pt, circle(radius: 0.9pt, fill: ink(80%)))
    }
  }
}

#for (row, col, price, n) in data.cells {
  let lon = lon0 + (col + calc.rem(row, 2) / 2) * g.dlon
  let lat = lat0 - row * g.dlat
  let (x, y) = proj((lon, lat))
  let p = norm(price)
  let r = 0.9pt + 2.6pt * (1 - p)
  place(dx: x - r, dy: y - r, circle(radius: r, fill: ink(15% + 60% * p)))
}

// Your station: the cheapest one just south of Madrid, pinging.
#let (sx, sy) = proj((data.home.lon, data.home.lat))
#place(dx: sx - 8pt, dy: sy - 8pt, circle(radius: 8pt, fill: white))
#for (i, r) in (18pt, 30pt, 42pt).enumerate() {
  place(dx: sx - r, dy: sy - r, circle(radius: r, stroke: 3pt + ink(20% + i * 25%)))
}

// The notification, out over the Mediterranean.
#let (nx, ny) = (740pt, sy - 110pt)
#place(dx: nx, dy: ny, {
  place(rect(width: 196pt, height: 64pt, radius: 14pt, fill: white))
  place(dx: 16pt, dy: 12pt, text(size: 16pt, fill: rgb("#b42318").transparentize(30%))[Your
    station])
  place(dx: 16pt, dy: 32pt, text(size: 22pt, weight: "bold", fill: rgb("#b42318"))[−4 cts · #euros(
      data.home.price,
    )])
})
#place(line(start: (sx + 12pt, sy - 10pt), end: (nx, ny + 40pt), stroke: 3pt + white))

// Legend, in the Atlantic.
#place(dx: 56pt, dy: 392pt, {
  set text(size: 17pt, fill: ink(20%))
  place(dy: 0pt)[#euros(lo)]
  for (i, p) in (0, 0.25, 0.5, 0.75, 1).enumerate() {
    let r = 0.9pt + 2.6pt * (1 - p)
    place(dx: 64pt + i * 16pt - r, dy: 10pt - r, circle(radius: r, fill: ink(15% + 60% * p)))
  }
  place(dx: 144pt, dy: 0pt)[#euros(hi)]
  place(dy: 34pt, text(size: 15pt, fill: ink(40%))[#{
      let s = str(data.stations)
      s.slice(0, s.len() - 3) + " " + s.slice(s.len() - 3)
    } stations · #data.date])
})
