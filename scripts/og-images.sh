#!/bin/sh
# Tola before-build hook: link previews (Open Graph) don't accept SVG, so render every SVG image
# in static/web-assets/images/ to a 1200px-wide PNG in static/og-images/ (published at /og/).
# The square logo layers are skipped; logo-wide.svg is the preview for pages without a hero.
# Only SVGs newer than their PNG are re-rendered, so dev rebuilds stay fast. Needs `rsvg-convert`, or
# `resvg` where rsvg-convert isn't packaged, as on Windows (`scoop install resvg`).
set -eu
if command -v rsvg-convert >/dev/null 2>&1; then
  render() { rsvg-convert --width 1200 --keep-aspect-ratio "$1" -o "$2"; }
elif command -v resvg >/dev/null 2>&1; then
  render() { resvg --width 1200 "$1" "$2"; }
else
  echo "og-images: needs rsvg-convert or resvg to render the link previews" >&2
  exit 1
fi
src="static/web-assets/images"
out="static/og-images"
mkdir -p "$out"
for svg in "$src"/*.svg; do
  name=$(basename "$svg" .svg)
  case "$name" in logo | logo-bg | logo-fg) continue ;; esac
  png="$out/$name.png"
  if [ ! -f "$png" ] || [ "$svg" -nt "$png" ]; then
    render "$svg" "$png.tmp"
    mv "$png.tmp" "$png"
  fi
done
# Drop PNGs whose SVG is gone.
for png in "$out"/*.png; do
  [ -e "$png" ] || continue
  [ -f "$src/$(basename "$png" .png).svg" ] || rm "$png"
done
