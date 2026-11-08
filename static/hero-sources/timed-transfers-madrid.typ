// Hero for /blog/timed-transfers-madrid/: a time–space (Marey) diagram. Rows are places, time runs
// left to right; steep lines are trains, shallow ones are buses feeding the hub. One bus is met by
// a train that waits for it (the bright dwell), the next one arrives just after its train has left.
// Render: typst compile --font-path static/typst-fonts --format svg static/hero-sources/timed-transfers-madrid.typ static/web-assets/images/timed-transfers-madrid.svg
#import "_common.typ": *
#show: hero.with(rgb("#2b6cb0"), rgb("#1a2a4f"))

#let x0 = 170pt
#let x1 = 960pt
#let rows = (("Bus stop", 110pt), ("Hub", 270pt), ("City", 430pt))
#let hub = 270pt

// Rows and time ticks.
#for (name, y) in rows {
  place(line(start: (x0, y), end: (x1, y), stroke: 1.5pt + ink(70%)))
  place(dx: 0pt, dy: y - 9pt, box(width: x0 - 24pt, align(right, text(
    size: 20pt,
    fill: ink(30%),
    name,
  ))))
}
#for i in range(0, 14) {
  let x = x0 + i * 60pt
  place(line(start: (x, 90pt), end: (x, 450pt), stroke: (paint: ink(90%), thickness: 1pt)))
}

// Trains: steep, through the hub, with a short dwell there. `dep` is when they leave the hub.
#let train(arr, dep, paint) = {
  let s = 2.2 // pt of time per pt of space: steep
  place(line(start: (arr - (hub - 90pt) / s, 90pt), end: (arr, hub), stroke: 5pt + paint))
  place(line(start: (arr, hub), end: (dep, hub), stroke: 5pt + paint))
  place(line(start: (dep, hub), end: (dep + (450pt - hub) / s, 450pt), stroke: 5pt + paint))
}
// Buses: shallow, from the stop down to the hub.
#let bus(arr, paint) = place(line(start: (arr - 200pt, 110pt), end: (arr, hub), stroke: (
  paint: paint,
  thickness: 4pt,
  cap: "round",
)))

#train(230pt, 245pt, ink(45%))
#train(500pt, 560pt, white) // held: waits for the bus
#train(800pt, 815pt, ink(45%))

#bus(540pt, white)
#bus(860pt, ink(25%))

// The transfer that works: a ring where bus meets train.
#place(dx: 540pt - 14pt, dy: hub - 14pt, circle(radius: 14pt, stroke: 3pt + white))
#place(dx: 470pt, dy: hub + 26pt, text(size: 18pt)[held])

// The one that doesn't: a dashed bracket over the gap.
#place(line(start: (815pt, hub - 26pt), end: (860pt, hub - 26pt), stroke: (
  paint: white,
  thickness: 2pt,
  dash: "dashed",
)))
#place(line(start: (815pt, hub - 34pt), end: (815pt, hub - 18pt), stroke: 2pt + white))
#place(line(start: (860pt, hub - 34pt), end: (860pt, hub - 18pt), stroke: 2pt + white))
#place(dx: 868pt, dy: hub - 40pt, text(size: 18pt, fill: ink(20%))[missed])
