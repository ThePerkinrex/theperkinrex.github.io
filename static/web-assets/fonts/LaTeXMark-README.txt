LaTeXMark-Regular.woff2 and LaTeXMark-Bold.woff2 are subsets of New Computer Modern 10
(NewCM10-Regular.otf and NewCM10-Bold.otf from TeX Live), cut down to the letters L, A, T, E and X
for the `#latex` mark (site/components.typ, `.latex-mark` in css/site.css).

New Computer Modern is by Antonis Tsolomitis and is distributed under the GUST Font License:
https://www.gust.org.pl/projects/e-foundry/licenses
Source: https://ctan.org/pkg/newcomputermodern

Regenerate with fontTools (`pyftsubset`):
  pyftsubset NewCM10-Regular.otf --text=LATEX --flavor=woff2 --layout-features='' --no-hinting \
    --desubroutinize --name-IDs='*' --output-file=LaTeXMark-Regular.woff2
