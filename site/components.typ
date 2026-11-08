// Components posts can use: `#import "/site/components.typ": *`
// (admonitions and `csv-table`).

/// A stroke icon (24×24, Lucide-style) drawn with the current text colour.
#let icon(..parts) = html.elem(
  "svg",
  attrs: (
    viewBox: "0 0 24 24",
    width: "20",
    height: "20",
    fill: "none",
    stroke: "currentColor",
    "stroke-width": "2",
    "stroke-linecap": "round",
    "stroke-linejoin": "round",
    "aria-hidden": "true",
  ),
  parts.pos().map(part => if type(part) == str { html.elem("path", attrs: (d: part)) } else { part }).join(),
)

#let circle = html.elem("circle", attrs: (cx: "12", cy: "12", r: "10"))

#let admonition-kinds = (
  note: (title: "Note", icon: icon(circle, "M12 16v-4", "M12 8h.01")),
  tip: (
    title: "Tip",
    icon: icon(
      "M15 14c.2-1 .7-1.7 1.5-2.5 1-.9 1.5-2.2 1.5-3.5A6 6 0 0 0 6 8c0 1 .2 2.2 1.5 3.5.7.7 1.3 1.5 1.5 2.5",
      "M9 18h6",
      "M10 22h4",
    ),
  ),
  important: (title: "Important", icon: icon(circle, "M12 8v4", "M12 16h.01")),
  warning: (
    title: "Warning",
    icon: icon("m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3", "M12 9v4", "M12 17h.01"),
  ),
  caution: (
    title: "Caution",
    icon: icon(
      "M15.312 2a2 2 0 0 1 1.414.586l4.688 4.688A2 2 0 0 1 22 8.688v6.624a2 2 0 0 1-.586 1.414l-4.688 4.688a2 2 0 0 1-1.414.586H8.688a2 2 0 0 1-1.414-.586l-4.688-4.688A2 2 0 0 1 2 15.312V8.688a2 2 0 0 1 .586-1.414l4.688-4.688A2 2 0 0 1 8.688 2z",
      "M12 8v4",
      "M12 16h.01",
    ),
  ),
)

/// A callout box. `kind` is one of note, tip, important, warning, caution.
#let admonition(kind, title: auto, body) = {
  assert(kind in admonition-kinds, message: "unknown admonition kind `" + kind + "`")
  let spec = admonition-kinds.at(kind)
  html.aside(class: "admonition " + kind)[
    #html.p(class: "admonition-title", {
      spec.icon
      html.span(if title == auto { spec.title } else { title })
    })
    #body
  ]
}

#let note = admonition.with("note")
#let tip = admonition.with("tip")
#let important = admonition.with("important")
#let warning = admonition.with("warning")
#let caution = admonition.with("caution")

/// A table from parsed CSV rows whose first row is the header: `#csv-table(csv("data.csv"))`.
/// Call `csv` in the post itself, so the path resolves next to the post.
#let csv-table(rows) = {
  let (header, ..body) = rows
  table(
    columns: header.len(),
    table.header(..header.map(cell => [#cell])),
    ..body.flatten().map(cell => [#cell]),
  )
}
