// Hero for /blog/fuel-price-tracker/: the national average price, then a dashed 14-day forecast
// inside a widening band, a fuel pump on the left and station pins along the bottom.
// Render: typst compile --font-path static/typst-fonts --format svg static/hero-sources/fuel-price-tracker.typ static/web-assets/images/fuel-price-tracker.svg
#import "_common.typ": *
#show: hero.with(rgb("#f59e0b"), rgb("#b42318"))

#let x0 = 300pt
#let xf = 760pt // where the forecast starts
#let x1 = 960pt
#let price(t) = 230pt - 40pt * calc.sin(t * 2.3) - 22pt * calc.sin(t * 7.1 + 1) - 8pt * calc.sin(t * 19.0) + 30pt * t
#let n = 160
#let xs(i, a, b) = a + (b - a) * i / n
#let t-of(x) = (x - x0) / (x1 - x0) * 3

// Axis.
#place(line(start: (x0, 400pt), end: (x1, 400pt), stroke: 2pt + ink(50%)))
#place(line(start: (x0, 90pt), end: (x0, 400pt), stroke: 2pt + ink(50%)))
#place(dx: x0 - 14pt, dy: 66pt, text(size: 22pt, weight: "bold", fill: ink(20%))[€/L])

// History.
#let hist = range(0, n + 1).map(i => { let x = xs(i, x0, xf); (x, price(t-of(x))) })
#place(curve(stroke: (paint: white, thickness: 5pt, join: "round"),
  curve.move(hist.first()), ..hist.slice(1).map(p => curve.line(p))))

// Forecast: a straight-ish dashed line inside a widening band.
#let y0 = price(t-of(xf))
#let fc(x) = y0 - (x - xf) * 0.12
#let spread(x) = (x - xf) * 0.38
#let m = 40
#let fx(i) = xf + (x1 - xf) * i / m
#place(polygon(fill: ink(78%),
  ..range(0, m + 1).map(i => (fx(i), fc(fx(i)) - spread(fx(i)))),
  ..range(0, m + 1).rev().map(i => (fx(i), fc(fx(i)) + spread(fx(i))))))
#place(line(start: (xf, y0), end: (x1, fc(x1)), stroke: (paint: white, thickness: 5pt, dash: (12pt, 9pt), cap: "round")))
#place(line(start: (xf, 90pt), end: (xf, 400pt), stroke: (paint: ink(60%), thickness: 1.5pt, dash: "dotted")))
#place(dx: xf + 10pt, dy: 92pt, text(size: 18pt, fill: ink(25%))[forecast])

// Station pins along the axis.
#for x in (350pt, 420pt, 470pt, 560pt, 640pt, 700pt, 820pt, 900pt) {
  place(dx: x - 9pt, dy: 418pt, {
    place(circle(radius: 9pt, fill: ink(35%)))
    place(dx: 2pt, dy: 12pt, polygon(fill: ink(35%), (0pt, 0pt), (14pt, 0pt), (7pt, 12pt)))
    place(dx: 5pt, dy: 5pt, circle(radius: 4pt, fill: rgb("#d4541a")))
  })
}

// The pump.
#place(dx: 90pt, dy: 140pt, {
  place(rect(width: 110pt, height: 210pt, radius: (top: 14pt), stroke: 6pt + white))
  place(dx: 18pt, dy: 22pt, rect(width: 74pt, height: 52pt, radius: 4pt, fill: white))
  place(dx: 26pt, dy: 30pt, text(size: 22pt, weight: "bold", font: "Atkinson Hyperlegible Mono", fill: rgb("#d4541a"))[1,62])
  place(dx: -20pt, dy: 210pt, line(length: 150pt, stroke: 6pt + white))
  // Hose and nozzle.
  place(curve(stroke: (paint: white, thickness: 6pt, cap: "round"),
    curve.move((110pt, 100pt)),
    curve.cubic((150pt, 100pt), (150pt, 170pt), (155pt, 50pt)),
  ))
  place(dx: 142pt, dy: 30pt, rect(width: 26pt, height: 30pt, radius: 4pt, fill: white))
})
