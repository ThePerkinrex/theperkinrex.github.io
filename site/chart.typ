// Charts: a post describes a chart once, as data, and it is drawn twice. The web page gets an
// interactive chart (uPlot, driven by `scripts/chart.js` from a JSON copy of the description); the
// PDF gets a static one drawn here with Lilaq. The two look alike but are not pixel-identical.
//
//   #chart(
//     panel(
//       [Average price, € per litre],
//       series("Petrol 95", dates, prices),
//       y: (lim: (0.9, 2.4), ticks: (1, 1.5, 2)),
//       format: (prefix: "€", digits: 2),
//     ),
//     events: (event(datetime(...), "COVID lockdown", short: "COVID"),),
//     alt: "What the chart shows, for screen readers",
//   )
//
// The x axis is time (native dates). Series take their colour from a fixed, colour-blind-checked
// palette by their order in a panel, or by `color: n` to keep one entity's colour across panels.

#import "@preview/lilaq:0.6.0" as lq
#import "@tola/address:0.0.0": asset-url
#import "theme.typ": body-font, palette

/// Series colours, in the order series take them: light and dark steps of each hue, validated for
/// colour-blind separation and contrast against the site's light and dark backgrounds.
#let chart-palette = (
  light: (rgb("#2a78d6"), rgb("#eb6834"), rgb("#1baf7a"), rgb("#6250d6")),
  dark: (rgb("#3987e5"), rgb("#d95926"), rgb("#199e70"), rgb("#9085e9")),
)

/// A line (`kind: "line"`) or step line (`kind: "step"`, each value held until the next x) of
/// `ys` (numbers, or `none` for a gap) over `xs` (dates). `color` is a 1-based palette slot.
#let series(name, xs, ys, kind: "line", color: auto) = {
  assert(kind in ("line", "step"), message: "a series is a \"line\" or a \"step\"")
  assert(
    xs.len() == ys.len(),
    message: "series `" + name + "` has " + str(xs.len()) + " x and " + str(ys.len()) + " y values",
  )
  (name: name, xs: xs, ys: ys, kind: kind, color: color)
}

/// A dashed vertical rule at `date` across every panel, labelled at the top of the first one.
/// `short` replaces `label` on narrow screens; `side` is where the label sits.
#let event(date, label, short: none, side: right) = (
  date: date,
  label: label,
  short: if short == none { label } else { short },
  side: side,
)

/// A shaded stretch of time across every panel, from `from` to `to` (or the end of the axis),
/// labelled just left of where it starts.
#let band(from, to: none, label: none, short: none) = (
  from: from,
  to: to,
  label: label,
  short: if short == none { label } else { short },
)

/// One stacked plot. `y`: `(lim: (lo, hi), ticks: (...))`. `format` sets how values read:
/// `(prefix:, suffix:, digits:)` on the axis, with `readout-digits` for the web's live values.
/// `end-labels` writes each series' last value at its end. `height` is in points/CSS pixels.
#let panel(
  title,
  ..series,
  short-title: none,
  y: (:),
  format: (:),
  end-labels: false,
  height: 200,
) = {
  assert(series.named().len() == 0, message: "unexpected named argument in `panel`")
  let format = (prefix: "", suffix: "", digits: 0) + format
  if "readout-digits" not in format { format.readout-digits = format.digits }
  (
    title: title,
    short-title: if short-title == none { title } else { short-title },
    series: series.pos(),
    y: y,
    format: format,
    end-labels: end-labels,
    height: height,
  )
}

// Shared helpers.

#let epoch = datetime(year: 1970, month: 1, day: 1)
#let day-number(d) = int((d - epoch).days())
#let from-day-number(n) = epoch + duration(days: n)

#let fixed(v, digits) = {
  if digits == 0 { return str(int(calc.round(v))) }
  let (whole, ..rest) = str(calc.round(v, digits: digits)).split(".")
  let frac = rest.at(0, default: "")
  whole + "." + frac + "0" * (digits - frac.len())
}
#let format-value(v, format, digits: auto) = {
  format.prefix + fixed(v, if digits == auto { format.digits } else { digits }) + format.suffix
}

/// The x range: the earliest and latest x over every series, plus a day, unless given.
#let x-range(panels, xlim) = {
  if xlim != auto { return xlim }
  let xs = panels.map(p => p.series.map(s => s.xs).flatten()).flatten()
  let days = xs.map(day-number)
  (from-day-number(calc.min(..days)), from-day-number(calc.max(..days) + 1))
}

#let color-index(s, i) = if s.color == auto { i } else { s.color - 1 }

// Web: the description as JSON, for scripts/chart.js.

/// Dates as day numbers; an evenly spaced run is stored as `(start, step, count)`.
#let encode-xs(xs) = {
  let days = xs.map(day-number)
  let steps = days.windows(2).map(((a, b)) => b - a).dedup()
  if days.len() > 2 and steps.len() == 1 {
    (start: days.first(), step: steps.first(), count: days.len())
  } else { days }
}

#let to-text(body) = if type(body) == str { body } else if body.has("text") {
  body.text
} else if body.has("children") {
  body.children.map(to-text).join()
} else if body == [ ] { " " } else { "" }

#let web-spec(panels, events, bands, xlim) = {
  let (x0, x1) = x-range(panels, xlim)
  (
    x: (min: day-number(x0), max: day-number(x1)),
    palette: (
      light: chart-palette.light.map(c => c.to-hex()),
      dark: chart-palette.dark.map(c => c.to-hex()),
    ),
    events: events.map(e => (
      x: day-number(e.date),
      label: e.label,
      short: e.short,
      side: if e.side == left { "left" } else { "right" },
    )),
    bands: bands.map(b => (
      from: day-number(b.from),
      to: if b.to == none { none } else { day-number(b.to) },
      label: b.label,
      short: b.short,
    )),
    panels: panels.map(p => (
      title: to-text(p.title),
      short-title: to-text(p.short-title),
      height: p.height,
      y: p.y,
      format: p.format,
      end-labels: p.end-labels,
      series: p
        .series
        .enumerate()
        .map(((i, s)) => (
          name: s.name,
          kind: s.kind,
          color: color-index(s, i),
          x: encode-xs(s.xs),
          y: s.ys.map(v => if v == none { none } else {
            calc.round(v, digits: p.format.readout-digits + 1)
          }),
        )),
    )),
  )
}

// PDF: the same description drawn with Lilaq.

/// Average a long series into about `buckets` points: more would only add file size on paper.
#let thin(xs, ys, buckets) = {
  let n = xs.len()
  if n <= buckets { return (xs, ys) }
  let (txs, tys) = ((), ())
  for b in range(buckets) {
    let (i0, i1) = (
      int(b * n / buckets),
      calc.max(int((b + 1) * n / buckets), int(b * n / buckets) + 1),
    )
    let vs = ys.slice(i0, i1).filter(v => v != none)
    if vs.len() > 0 {
      txs.push(xs.at(int((i0 + i1 - 1) / 2)))
      tys.push(vs.sum() / vs.len())
    }
  }
  (txs, tys)
}

/// Year ticks for a long axis, month ticks for a short one.
#let time-ticks(x0, x1) = {
  if x1.year() - x0.year() >= 3 {
    let years = range(
      x0.year() + if x0.month() == 1 and x0.day() == 1 { 0 } else { 1 },
      x1.year() + 1,
    )
    years.map(y => (datetime(year: y, month: 1, day: 1), str(y)))
  } else {
    let ticks = ()
    let d = datetime(year: x0.year(), month: x0.month(), day: 1)
    if d < x0 {
      d = if d.month() == 12 { datetime(year: d.year() + 1, month: 1, day: 1) } else {
        datetime(year: d.year(), month: d.month() + 1, day: 1)
      }
    }
    while d <= x1 {
      ticks.push((d, d.display("[month repr:short] [year repr:last_two]")))
      d = if d.month() == 12 { datetime(year: d.year() + 1, month: 1, day: 1) } else {
        datetime(year: d.year(), month: d.month() + 1, day: 1)
      }
    }
    ticks
  }
}

#let paged-chart(panels, events, bands, xlim) = layout(available => {
  set text(font: body-font, size: 9pt, fill: palette.muted)
  set align(left)
  show: lq.set-diagram(
    xaxis: (subticks: none, mirror: false, stroke: palette.line),
    yaxis: (subticks: none, mirror: false, stroke: none),
  )
  show: lq.set-grid(stroke: 0.5pt + palette.line)
  show: lq.set-tick(stroke: 0.5pt + palette.line, inset: 0pt, outset: 3pt, pad: 4pt)

  let small = 8pt
  let (x0, x1) = x-range(panels, xlim)
  let ticks = time-ticks(x0, x1)
  // Fixed-width y labels, so every panel's plot area starts at the same x.
  let label-w = 30pt
  let ylabel(s) = box(width: label-w, align(right, s))
  let right-room = if panels.any(p => p.end-labels) { 40pt } else { 8pt }
  let width = available.width - label-w - 8pt - right-room
  let rule = (paint: palette.muted, thickness: 0.6pt, dash: (2pt, 2pt))

  // One legend for the whole chart: every series name once, in its colour.
  let named = (:)
  for p in panels {
    for (i, s) in p.series.enumerate() {
      if s.name not in named { named.insert(s.name, chart-palette.light.at(color-index(s, i))) }
    }
  }
  let legend = {
    set text(fill: palette.text)
    stack(dir: ltr, spacing: 10pt, ..named
      .pairs()
      .map(((name, c)) => stack(
        dir: ltr,
        spacing: 4pt,
        box(height: 0.7em, align(horizon, line(length: 12pt, stroke: 1.5pt + c))),
        name,
      )))
  }
  let title(body) = text(fill: palette.text, weight: "bold", body)

  for (k, p) in panels.enumerate() {
    let (lo, hi) = p.y.lim
    let height = p.height * 0.75pt
    let last = k == panels.len() - 1
    if k == 0 {
      block(below: 5pt, grid(
        columns: (1fr, auto),
        title(p.title), legend,
      ))
    } else {
      v(10pt)
      block(below: 5pt, title(p.title))
    }
    let label-y = hi - (hi - lo) * 0.05
    let diagram = lq.diagram(
      width: width,
      height: height,
      xlim: (x0, x1),
      ylim: (lo, hi),
      margin: 0%,
      xaxis: (ticks: ticks.map(((d, s)) => (d, if last { s } else { none }))),
      yaxis: (ticks: p.y.ticks.map(v => (v, ylabel(format-value(v, p.format))))),
      ..bands.map(b => lq.fill-between(
        (b.from, if b.to == none { x1 } else { b.to }),
        (hi, hi),
        y2: (lo, lo),
        fill: palette.code-bg,
        stroke: none,
        z-index: 0,
      )),
      ..events.map(e => lq.vlines(e.date, stroke: rule, z-index: 1)),
      ..if k == 0 {
        events.map(e => lq.place(
          e.date,
          label-y,
          align: (if e.side == left { right } else { left }) + horizon,
          pad(x: 3pt, text(size: small, e.label)),
        ))
        bands
          .filter(b => b.label != none)
          .map(b => lq.place(
            b.from,
            label-y,
            align: right + horizon,
            pad(x: 3pt, text(size: small, b.label)),
          ))
      },
      ..p
        .series
        .enumerate()
        .map(((i, s)) => {
          let (xs, ys) = if s.kind == "step" { (s.xs, s.ys) } else {
            thin(s.xs, s.ys, int(width / 1pt))
          }
          // A step line holds its last value until the end of the axis.
          if s.kind == "step" { (xs, ys) = (xs + (x1,), ys + (ys.last(),)) }
          lq.plot(
            xs,
            ys,
            mark: none,
            step: if s.kind == "step" { start } else { none },
            stroke: 1.2pt + chart-palette.light.at(color-index(s, i)),
            z-index: 2,
          )
        }),
      ..if p.end-labels {
        // The last value of each series at its end, nudged apart when they would overlap.
        let ends = p
          .series
          .enumerate()
          .map(((i, s)) => {
            let j = s.ys.len() - 1 - s.ys.rev().position(v => v != none)
            (x: s.xs.at(j), v: s.ys.at(j), c: chart-palette.light.at(color-index(s, i)))
          })
        let gap = (hi - lo) * (9pt / height) * 1.25
        let ys = ends.map(e => e.v)
        let order = range(ys.len()).sorted(key: i => -ys.at(i))
        for (a, b) in order.windows(2) {
          if ys.at(a) - ys.at(b) < gap { ys.at(b) = ys.at(a) - gap }
        }
        ends
          .zip(ys)
          .map(((e, ly)) => (
            lq.scatter((e.x,), (e.v,), color: e.c, size: 4pt, stroke: none, z-index: 3),
            lq.place(e.x, ly, align: left + horizon, clip: false, pad(left: 5pt, text(
              fill: palette.text,
              format-value(e.v, p.format),
            ))),
          ))
          .flatten()
      },
      legend: none,
    )
    diagram
  }
})

/// A chart: one or more `panel`s stacked on a shared time axis, with `events` and `bands` marked
/// across them. `alt` describes it for screen readers and for readers without JavaScript; put
/// the numbers themselves in a table next to it. `xlim`: the time range, or `auto` for the data's.
#let chart(..panels, events: (), bands: (), xlim: auto, alt: none) = {
  assert(panels.named().len() == 0, message: "unexpected named argument in `chart`")
  assert(alt != none, message: "a chart needs an `alt` text")
  let panels = panels.pos()
  context if target() == "html" {
    html.elem(
      "div",
      attrs: (
        class: "chart",
        "data-uplot-js": asset-url("/assets/vendor/uplot/uPlot.iife.min.js"),
        "data-uplot-css": asset-url("/assets/vendor/uplot/uPlot.min.css"),
      ),
      {
        html.p(class: "chart-fallback", alt)
        html.script(type: "application/json", json.encode(
          web-spec(panels, events, bands, xlim),
          pretty: false,
        ))
        html.script("", type: "module", src: asset-url("/assets/scripts/chart.js"))
      },
    )
  } else {
    block(width: 100%, paged-chart(panels, events, bands, xlim))
  }
}
