"""Build the official Typst wordmark as a small font, for the web and for the PDFs:
static/web-assets/fonts/TypstMark.woff2 and static/typst-fonts/TypstMark.otf.

The `#typst` component (site/components.typ) writes the word "Typst" as text in this font, so the
page and the PDF show the wordmark while reader mode, copy-paste, search and screen readers get
the word.

The outlines come from static/hero-sources/typst-wordmark-white.svg (viewBox 91×35, baseline 24.41
units down, paths t, y, p, s, t). Letters keep the wordmark's own spacing; "T" is a copy of the t,
as its own glyph so a PDF's text layer maps it back to "T", not "t". One wordmark unit is 0.87/35
em, the size the SVG rendering used.

Needs fontTools and brotli:  python3 scripts/typst-mark-font.py
"""

import re
from pathlib import Path

from fontTools.feaLib.builder import addOpenTypeFeaturesFromString
from fontTools.fontBuilder import FontBuilder
from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.t2CharStringPen import T2CharStringPen
from fontTools.pens.transformPen import TransformPen
from fontTools.svgLib.path import parse_path

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "static/hero-sources/typst-wordmark-white.svg"
WEB_OUTPUT = ROOT / "static/web-assets/fonts/TypstMark.woff2"
PDF_OUTPUT = ROOT / "static/typst-fonts/TypstMark.otf"

UPM = 1000
SCALE = UPM * 0.87 / 35  # font units per wordmark unit
BASELINE = 24.41
HEIGHT = 35


def bounds(d):
    pen = BoundsPen(None)
    parse_path(d, pen)
    return pen.bounds


paths = re.findall(r'\bd="([^"]+)"', SOURCE.read_text())
assert len(paths) == 5, f"expected the 5 letters of the wordmark, found {len(paths)} paths"
letters = dict(zip(["t", "y", "p", "s"], paths))
letters["T"] = letters["t"]
starts = [bounds(d)[0] for d in paths]  # left edge of each letter, in wordmark order
t_width = bounds(paths[0])[2] - starts[0]

# Advance = distance to the next letter's left edge. The t gets its full width so a final t does
# not touch what follows; the t→y pair is kerned back to the wordmark's spacing.
advances = {
    "t": t_width,
    "T": t_width,
    "y": starts[2] - starts[1],
    "p": starts[3] - starts[2],
    "s": starts[4] - starts[3],
}
kern_t_y = (starts[1] - starts[0]) - t_width

glyph_order = [".notdef", "space", "T", "t", "y", "p", "s"]
charstrings, metrics = {}, {}
for name in glyph_order:
    pen = T2CharStringPen(0, None)
    if name in letters:
        x0 = bounds(letters[name])[0]
        parse_path(letters[name], TransformPen(pen, (SCALE, 0, 0, -SCALE, -x0 * SCALE, BASELINE * SCALE)))
        width = round(advances[name] * SCALE)
    else:
        width = round(0.25 * UPM)
    charstrings[name] = pen.getCharString()
    metrics[name] = (width, 0)

ascent, descent = round(BASELINE * SCALE), round((HEIGHT - BASELINE) * SCALE)
fb = FontBuilder(UPM, isTTF=False)
fb.setupGlyphOrder(glyph_order)
fb.setupCharacterMap({0x20: "space", ord("t"): "t", ord("T"): "T", ord("y"): "y", ord("p"): "p", ord("s"): "s"})
fb.setupCFF("TypstMark", {"FullName": "Typst Mark"}, charstrings, {})
fb.setupHorizontalMetrics(metrics)
fb.setupHorizontalHeader(ascent=ascent, descent=-descent)
fb.setupNameTable({"familyName": "Typst Mark", "styleName": "Regular", "psName": "TypstMark-Regular"})
fb.setupOS2(
    sTypoAscender=ascent, sTypoDescender=-descent, usWinAscent=ascent, usWinDescent=descent,
    sxHeight=round(20 * SCALE),
)
fb.setupPost()
addOpenTypeFeaturesFromString(fb.font, f"feature kern {{ pos [T t] y {round(kern_t_y * SCALE)}; }} kern;")
for flavor, output in ((None, PDF_OUTPUT), ("woff2", WEB_OUTPUT)):
    fb.font.flavor = flavor
    fb.save(output)
    print(f"wrote {output.relative_to(ROOT)} ({output.stat().st_size} bytes)")
