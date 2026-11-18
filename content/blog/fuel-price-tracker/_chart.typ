// The fuel price chart in this post: Spain's average pump price per day (top) and how far it moved
// within each month (bottom). The data is `prices.json`, built by `summarize_prices.py`; rerun that
// and rebuild to update the chart, its labels and the table. `_`-prefixed files are helper modules,
// never pages (`is-module` in site/selection.typ).

#import "/site/chart.typ": band, chart, event, fixed, panel, series

#let data = json("prices.json")

#let parse-date(s) = datetime(
  year: int(s.slice(0, 4)),
  month: int(s.slice(5, 7)),
  day: if s.len() > 7 { int(s.slice(8, 10)) } else { 1 },
)
#let first-day = parse-date(data.start)
#let last-day = parse-date(data.end)
#let day(i) = first-day + duration(days: i)

#let fuels = ("gasolina_95", "gasoleo_a")
#let fuel-names = (gasolina_95: "Petrol 95", gasoleo_a: "Diesel")
#let month-names = (
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec",
)

#let euros(v) = "€" + fixed(v, 2)
#let prices(f) = data.at(f).map(v => if v == none { none } else { v / 1000 })
#let latest = fuels.map(f => (f, prices(f).filter(v => v != none).last())).to-dict()

/// Since this day the state has cut fuel taxes: VAT down to 10 % until July, and a cut in the
/// hydrocarbon tax until the end of 2026 (RDL 7/2026, 18/2026 and 25/2026).
#let tax-cut = datetime(year: 2026, month: 3, day: 22)

#let alt = {
  let peak = prices("gasolina_95")
    .enumerate()
    .filter(((_, v)) => v != none)
    .sorted(key: ((_, v)) => v)
    .last()
  let widest = data.spread.sorted(key: r => r.at(2)).last()
  (
    "Line chart of the average pump price in mainland Spain and the Balearics, daily from "
      + str(first-day.year())
      + " to "
      + last-day.display("[day] [month repr:long] [year]")
      + ", with each month's price swing below. Prices dip during the 2020 COVID lockdown, peak at "
      + euros(peak.at(1))
      + " for petrol in "
      + day(peak.at(0)).display("[month repr:long] [year]")
      + " after Russia invades Ukraine, settle around €1.50 through 2025, then jump again in "
      + parse-date(widest.at(0)).display("[month repr:long] [year]")
      + ", when diesel moved "
      + str(calc.round(widest.at(2)))
      + " cents within the month, the largest swing in the chart. Fuel tax cuts start on 22 March "
      + "2026. Latest: petrol "
      + euros(latest.gasolina_95)
      + ", diesel "
      + euros(latest.gasoleo_a)
      + "."
  )
}

#let fuel-price-chart = {
  let days = range(data.gasolina_95.len()).map(day)
  let months = data.spread.map(r => parse-date(r.at(0)))
  chart(
    panel(
      [Average price, € per litre],
      short-title: [Price, € per litre],
      ..fuels.map(f => series(fuel-names.at(f), days, prices(f))),
      y: (lim: (0.94, 2.36), ticks: range(5, 12).map(k => k / 5)),
      format: (prefix: "€", digits: 2, readout-digits: 3),
      end-labels: true,
      height: 260,
    ),
    panel(
      [Monthly swing: highest minus lowest day, cents],
      short-title: [Monthly swing, cents],
      ..fuels
        .enumerate()
        .map(((k, f)) => series(
          fuel-names.at(f),
          months,
          data.spread.map(r => r.at(k + 1)),
          kind: "step",
        )),
      y: (lim: (0, 60), ticks: (25, 50)),
      format: (suffix: " c", digits: 0, readout-digits: 1),
      height: 100,
    ),
    events: (
      event(datetime(year: 2020, month: 3, day: 14), "COVID lockdown", short: "COVID"),
      event(datetime(year: 2022, month: 2, day: 24), "Russia invades Ukraine", short: "Ukraine"),
    ),
    bands: (band(tax-cut, label: "Tax cuts"),),
    xlim: (first-day, last-day + duration(days: 1)),
    alt: alt,
  )
}

/// One row per year: each fuel's average price and its widest monthly swing (and its month).
#let fuel-price-table = {
  let years = range(first-day.year(), last-day.year() + 1)
  let average(f, year) = {
    let vs = prices(f)
      .enumerate()
      .filter(((i, v)) => v != none and day(i).year() == year)
      .map(((_, v)) => v)
    euros(vs.sum() / vs.len())
  }
  let swing(k, year) = {
    let rows = data.spread.filter(r => r.at(0).starts-with(str(year)))
    if rows.len() == 0 { return [–] }
    let row = rows.sorted(key: r => r.at(k + 1)).last()
    [#fixed(row.at(k + 1), 1) c (#month-names.at(int(row.at(0).slice(5, 7)) - 1))]
  }
  table(
    columns: 5,
    table.header([Year], [Petrol 95], [Diesel], [Petrol 95 swing], [Diesel swing]),
    ..years
      .map(year => (
        if year == last-day.year() [#year (to #last-day.display(
            "[day] [month repr:short]",
          ))] else [#year],
        average("gasolina_95", year),
        average("gasoleo_a", year),
        swing(0, year),
        swing(1, year),
      ))
      .flatten(),
  )
}
