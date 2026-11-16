"""Shrink a full fuel-price dump into the small summary the fuel-price-tracker hero reads.

The dump (fuel_prices_og.json, one object per station, ~4 MB) is not versioned. This bins the
mainland stations into the same staggered dot grid the hero draws and keeps the median
gasolina 95 price per dot, plus the cheapest station near "your station" for the ping.

Run: python static/hero-sources/summarize_fuel_prices.py [in.json] [out.json]
"""

import json
import math
import statistics
import sys
from pathlib import Path

HERE = Path(__file__).parent
SRC = Path(sys.argv[1]) if len(sys.argv) > 1 else HERE / "fuel_prices_og.json"
DST = Path(sys.argv[2]) if len(sys.argv) > 2 else HERE / "fuel_prices.json"

FUEL = "gasolina_95"
NOT_MAINLAND = ("BALEARS", "PALMAS", "TENERIFE", "CEUTA", "MELILLA")

# Grid, in degrees. Matches the hero's projection: 58pt per degree of latitude, lon scaled by
# cos(40°) ≈ 0.766, dots every 8.5pt horizontally and 8.5pt * 0.87 vertically, odd rows shifted
# half a step.
LON0, LAT0 = -9.4, 43.9
DLON = 8.5 / (58 * 0.766)
DLAT = 8.5 * 0.87 / 58

# Where "your station" is, roughly: south of Madrid.
HOME = (-3.75, 40.3)
HOME_RADIUS_KM = 15


def cell(lon, lat):
    row = round((LAT0 - lat) / DLAT)
    col = round((lon - LON0) / DLON - (row % 2) / 2)
    return row, col


def km(a, b):
    (lon1, lat1), (lon2, lat2) = a, b
    x = math.radians(lon2 - lon1) * math.cos(math.radians((lat1 + lat2) / 2))
    y = math.radians(lat2 - lat1)
    return 6371 * math.hypot(x, y)


stations = json.loads(SRC.read_text(encoding="utf-8"))
mainland = [
    s for s in stations
    if s[FUEL] is not None and not any(p in s["provincia"] for p in NOT_MAINLAND)
]

cells = {}
for s in mainland:
    cells.setdefault(cell(s["longitud"], s["latitud"]), []).append(s[FUEL])

near_home = [s for s in mainland if km(HOME, (s["longitud"], s["latitud"])) < HOME_RADIUS_KM]
home = min(near_home, key=lambda s: s[FUEL])

summary = {
    "fuel": FUEL,
    "date": stations[0]["fecha"][:10],
    "stations": len(mainland),
    "grid": {"lon0": LON0, "lat0": LAT0, "dlon": round(DLON, 6), "dlat": round(DLAT, 6)},
    "home": {"lon": home["longitud"], "lat": home["latitud"], "price": home[FUEL]},
    # [row, col, median price, station count]
    "cells": [
        [r, c, round(statistics.median(v), 3), len(v)] for (r, c), v in sorted(cells.items())
    ],
}

DST.write_text(
    "{\n"
    + ",\n".join(f"  {json.dumps(k)}: {json.dumps(v, ensure_ascii=False)}" for k, v in summary.items() if k != "cells")
    + ',\n  "cells": [\n'
    + ",\n".join("    " + json.dumps(c, separators=(",", ":")) for c in summary["cells"])
    + "\n  ]\n}\n",
    encoding="utf-8",
)
print(f"{len(mainland)} stations -> {len(cells)} cells, {DST.stat().st_size} bytes -> {DST}")
