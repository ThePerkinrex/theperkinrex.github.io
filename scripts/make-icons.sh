#!/bin/sh
# Render the browser icons from the logo; rerun if logo.svg or favicon.svg changes. Needs
# `rsvg-convert` and ImageMagick (`magick`). The outputs are committed, so builds don't need ImageMagick.
#   static/favicon.ico          16, 32 and 48px from the rounded favicon.svg, for clients that fetch
#                               /favicon.ico directly
#   static/apple-touch-icon.png 180px from the square logo.svg, for iOS home screens (which ignore
#                               SVG icons and round the corners themselves)
set -eu
logo="static/web-assets/images/logo.svg"
favicon="static/web-assets/images/favicon.svg"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
for size in 16 32 48; do
  rsvg-convert --width "$size" --height "$size" "$favicon" -o "$tmp/$size.png"
done
magick "$tmp/16.png" "$tmp/32.png" "$tmp/48.png" static/favicon.ico
rsvg-convert --width 180 --height 180 "$logo" -o static/apple-touch-icon.png
