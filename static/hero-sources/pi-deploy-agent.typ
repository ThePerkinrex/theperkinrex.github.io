// Hero for /blog/pi-deploy-agent/: CI builds and seals a bundle, it travels over the tailnet to a
// Raspberry Pi, and under the Pi `current` points at the newest release.
// Render: typst compile --font-path static/typst-fonts --format svg static/hero-sources/pi-deploy-agent.typ static/web-assets/images/pi-deploy-agent.svg
#import "_common.typ": *
#show: hero.with(rgb("#1f7a54"), rgb("#1e293b"))

#let mid = 210pt

// The tailnet: a dotted line from CI to the Pi.
#place(line(start: (250pt, mid), end: (690pt, mid), stroke: (paint: ink(40%), thickness: 4pt, dash: (2pt, 12pt), cap: "round")))

// CI: a box with a gear.
#let gear(r) = {
  for i in range(0, 8) {
    place(dx: -7pt, dy: -r - 8pt, rotate(i * 45deg, origin: center + bottom, reflow: false,
      box(width: 14pt, height: r + 8pt, place(rect(width: 14pt, height: 14pt, radius: 2pt, fill: white)))))
  }
  place(dx: -r, dy: -r, circle(radius: r, fill: white))
  place(dx: -r * 0.42, dy: -r * 0.42, circle(radius: r * 0.42, fill: rgb("#1d6b4c")))
}
#place(dx: 70pt, dy: mid - 90pt, rect(width: 180pt, height: 180pt, radius: 18pt, stroke: 5pt + white))
#place(dx: 160pt, dy: mid - 10pt, gear(36pt))
#place(dx: 70pt, dy: mid + 104pt, box(width: 180pt, align(center, text(size: 22pt, fill: ink(20%))[CI])))

// The sealed bundle, mid-flight.
#place(dx: 400pt, dy: mid - 55pt, {
  place(rect(width: 130pt, height: 110pt, radius: 6pt, fill: rgb("#244a3e"), stroke: 5pt + white))
  place(dx: 0pt, dy: 30pt, line(length: 130pt, stroke: 3pt + ink(30%)))
  place(dx: 55pt, dy: 0pt, rect(width: 20pt, height: 30pt, fill: ink(30%)))
  place(dx: 75pt, dy: 52pt, circle(radius: 34pt, fill: rgb("#c2410c"), stroke: 3pt + white))
  place(dx: 75pt, dy: 52pt, box(width: 68pt, height: 68pt, align(center + horizon,
    text(size: 15pt, weight: "bold")[HMAC])))
})
#place(dx: 400pt, dy: mid + 72pt, box(width: 130pt, align(center, text(size: 18pt, font: "Atkinson Hyperlegible Mono", fill: ink(20%))[.tar.zst])))

// The Pi: a board with a GPIO header, a chip and ports.
#place(dx: 690pt, dy: mid - 90pt, {
  place(rect(width: 260pt, height: 170pt, radius: 12pt, fill: rgb("#244a3e"), stroke: 5pt + white))
  for i in range(0, 20) {
    for j in range(0, 2) {
      place(dx: 22pt + i * 11pt, dy: 14pt + j * 11pt, circle(radius: 3pt, fill: ink(20%)))
    }
  }
  place(dx: 70pt, dy: 66pt, rect(width: 62pt, height: 62pt, radius: 4pt, fill: white))
  place(dx: 150pt, dy: 76pt, rect(width: 40pt, height: 40pt, radius: 3pt, fill: ink(50%)))
  for k in range(0, 3) {
    place(dx: 236pt, dy: 46pt + k * 40pt, rect(width: 36pt, height: 30pt, radius: 3pt, fill: ink(20%)))
  }
  for c in (14pt, 230pt) { for r in (14pt, 140pt) {
    place(dx: c - 6pt, dy: r + 4pt, circle(radius: 6pt, stroke: 2pt + ink(40%)))
  } }
})

// releases/ under the Pi.
#place(dx: 720pt, dy: mid + 100pt, {
  set text(font: "Atkinson Hyperlegible Mono", size: 19pt)
  set par(leading: 0.5em)
  [#text(fill: ink(25%))[releases/] \
  #text(fill: ink(50%))[├ a3f9c1/] \
  #text(fill: ink(50%))[├ 7be210/] \
  └ e41d07/ #text(fill: rgb("#fdba74"), weight: "bold")[← current]]
})
