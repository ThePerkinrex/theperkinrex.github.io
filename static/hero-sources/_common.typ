// Shared page set-up for the post heroes: a 2:1 banner, a two-colour gradient and a faint dot grid.
#let W = 1020pt
#let H = 510pt

#let hero(from, to, body) = {
  set page(width: W, height: H, margin: 0pt, fill: gradient.linear(from, to, angle: 25deg))
  set text(font: "Atkinson Hyperlegible", fill: white)
  place(rect(width: W, height: H, fill: tiling(
    size: (24pt, 24pt),
    place(dx: 12pt - 1.6pt, dy: 12pt - 1.6pt, circle(
      radius: 1.6pt,
      fill: white.transparentize(88%),
    )),
  )))
  body
}

#let ink(pct) = white.transparentize(pct)
