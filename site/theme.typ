// Colours shared by the HTML-free (print/PDF) renderings. They mirror the light theme in
// `static/web-assets/css/site.css`; keep the two in step.

#let palette = (
  logo-blue: rgb("#4a86e8"),
  logo-teal: rgb("#5dd2c2"),
  text: rgb("#2a3533"),
  heading: rgb("#141c1b"),
  muted: rgb("#5b6d6a"),
  line: rgb("#dde6e4"),
  code-bg: rgb("#eef3f2"),
  accent: rgb("#2a63c9"),
  // `--teal-soft`: the logo teal at 22% over white.
  teal-soft: rgb("#5dd2c2").transparentize(78%),
  draft-bg: rgb("#f5c542"),
  draft-text: rgb("#2a2200"),
)

/// Admonition tints, as in `.admonition.<kind>` in site.css.
#let admonition-tints = (
  note: rgb("#4a86e8"),
  tip: rgb("#1a9a88"),
  important: rgb("#8a5cd6"),
  warning: rgb("#c98a06"),
  caution: rgb("#d9453b"),
)

#let body-font = "Atkinson Hyperlegible"
#let mono-font = "Atkinson Hyperlegible Mono"
