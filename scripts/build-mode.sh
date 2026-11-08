#!/bin/sh
# Tola before-build hook: tell the Typst program whether this is `tola dev` or a production build,
# and the current year (Tola builds cannot read the clock). Typst cannot read environment
# variables, so both are written to a small JSON file.
# The file is only rewritten when it changes, so dev rebuilds do not re-trigger themselves.
set -eu
out="site/build-mode.json"
if [ "${TOLA_BUILD_MODE:-prod}" = "dev" ]; then dev=true; else dev=false; fi
new="{ \"dev\": $dev, \"year\": $(date +%Y) }"
if [ ! -f "$out" ] || [ "$(cat "$out")" != "$new" ]; then
  printf '%s\n' "$new" > "$out"
fi
