#!/bin/sh
# Tola before-build hook: link previews (Open Graph) don't accept SVG, so render every SVG image
# in static/web-assets/images/ to a 1200px-wide PNG in static/og-images/ (published at /og/).
# The square logo layers are skipped; logo-wide.svg is the preview for pages without a hero.
# Only SVGs newer than their PNG are re-rendered, so dev rebuilds stay fast. Needs `rsvg-convert`.
set -eu
src="static/web-assets/images"
out="static/og-images"
mkdir -p "$out"
for svg in "$src"/*.svg; do
  name=$(basename "$svg" .svg)
  case "$name" in logo | logo-bg | logo-fg) continue ;; esac
  png="$out/$name.png"
  if [ ! -f "$png" ] || [ "$svg" -nt "$png" ]; then
    rsvg-convert --width 1200 --keep-aspect-ratio "$svg" -o "$png.tmp"
    mv "$png.tmp" "$png"
  fi
done
# Drop PNGs whose SVG is gone.
for png in "$out"/*.png; do
  [ -e "$png" ] || continue
  [ -f "$src/$(basename "$png" .png).svg" ] || rm "$png"
done
