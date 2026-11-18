"""Build prices.json, the data behind the fuel price chart in this post, from the tracker's database.

It averages every station's price per day (mainland Spain and the Balearics: the Canaries, Ceuta
and Melilla have their own fuel taxes) from the per-province sums the downloader keeps, and the
spread of those daily averages within each month. The history before March 2026 is the Ministry's
daily record (backfilled); after that it is the tracker's own snapshots, four a day.

Run: python content/blog/fuel-price-tracker/summarize_prices.py [path/to/precios_carburantes.db | ssh-host]
The default reads the live database on the Pi over ssh (read-only).
"""

import csv
import datetime as dt
import io
import json
import sqlite3
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

SRC = sys.argv[1] if len(sys.argv) > 1 else "pi@raspberrypi"
REMOTE_DB = "/mnt/usb/carburantes/precios_carburantes.db"
DST = Path(__file__).with_name("prices.json")
START = dt.date(2019, 1, 1)
OWN_TAXES = ("05", "18", "19")  # Canarias, Ceuta, Melilla

QUERY = f"""
SELECT date(fecha, 'unixepoch', 'localtime') AS day,
       sum(suma_gasolina_95) / sum(n_gasolina_95),
       sum(suma_gasoleo_a) / sum(n_gasoleo_a)
FROM precios_provincia
WHERE id_ccaa NOT IN ({",".join(f"'{c}'" for c in OWN_TAXES)})
  AND fecha >= strftime('%s', '{START.isoformat()}')
GROUP BY day ORDER BY day
"""

if SRC.endswith(".db"):
    with sqlite3.connect(f"file:{SRC}?mode=ro", uri=True) as db:
        rows = db.execute(QUERY).fetchall()
else:
    out = subprocess.run(
        ["ssh", SRC, "sqlite3", "-readonly", "-csv", REMOTE_DB],
        input=QUERY + ";", check=True, capture_output=True, text=True,
    ).stdout
    rows = list(csv.reader(io.StringIO(out)))

daily = {dt.date.fromisoformat(d): (float(g), float(a)) for d, g, a in rows}
end = max(daily)

# One value per day from START, in thousandths of a euro (the stations' own precision); null on
# the rare day with no snapshot.
days = [START + dt.timedelta(n) for n in range((end - START).days + 1)]
series = {
    fuel: [round(daily[d][i] * 1000) if d in daily else None for d in days]
    for i, fuel in enumerate(("gasolina_95", "gasoleo_a"))
}

# Highest minus lowest daily average in each complete month, in cents.
months = defaultdict(list)
for d, prices in daily.items():
    months[d.strftime("%Y-%m")].append(prices)
spread = [
    [m, *(round((max(p[i] for p in v) - min(p[i] for p in v)) * 100, 1) for i in range(2))]
    for m, v in sorted(months.items())
    if m < end.strftime("%Y-%m")
]

summary = {
    "region": "mainland Spain and the Balearics",
    "start": START.isoformat(),
    "end": end.isoformat(),
    "missing": [d.isoformat() for d in days if d not in daily],
    "gasolina_95": series["gasolina_95"],
    "gasoleo_a": series["gasoleo_a"],
    # [month, gasolina 95 spread, gasóleo A spread] in cents
    "spread": spread,
}

DST.write_text(
    "{\n"
    + ",\n".join(f"  {json.dumps(k)}: {json.dumps(v, separators=(',', ':'))}" for k, v in summary.items())
    + "\n}\n",
    encoding="utf-8",
)
print(f"{len(daily)} days ({START} – {end}), {len(spread)} months, {DST.stat().st_size} bytes -> {DST}")
