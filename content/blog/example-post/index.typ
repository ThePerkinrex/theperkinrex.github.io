#import "@tola/source:0.0.0": tola-meta
// Admonitions, `asset-image`, `details`, `csv-table`: see site/components.typ. Posts are also
// typeset as a downloadable PDF, so use these components instead of `html.*` elements, which
// only exist on the web page.
#import "/site/components.typ": *

// Every field is declared in `site/schema.typ`.
#tola-meta((
  title: "Example post",
  description: "A kitchen-sink post showing everything a post can do. Never published.",
  date: "2026-11-07",
  // updated: "2026-11-09",
  tags: ("meta", "typst"),
  // A 2:1 banner (1020×510), preferably SVG, in `static/web-assets/images/`:
  // hero: "/assets/images/my-banner.svg",
  // Drafts appear under `tola dev` (with a badge) and are left out of `tola build`,
  // the RSS feed and the sitemap. Remove this line (or set it to false) to publish.
  draft: true,
))

// The post title, date and tags are rendered by the template (`site/page.typ`);
// start the body directly. `=` becomes an <h2>, `==` an <h3>, and so on.

#outline()

This is a reference post for writing new ones. Copy it to `content/blog/<slug>.typ` and the post
will live at `/blog/<slug>/`. A post that has its own files (data, bibliography) can be a folder
instead, like this one: `content/blog/<slug>/index.typ`.

= Text

Paragraphs are just text. You get *strong*, _emphasis_, `inline code`, #strike[strikethrough], and
#link("https://typst.app/docs")[links]. Links to other pages on this site use their route, like
#link("/about/")[the about page], and Tola checks they exist at build time.

#quote(block: true)[
  Blockquotes use the accent colour on their left border.
]

- Bullet lists
- with several
  - nested items

+ Numbered lists
+ work too

/ Term: and so do term lists.

Footnotes collect at the end of the post.#footnote[Like this one.] Each gets a link
back.#footnote[Footnotes can hold *markup* and #link("https://typst.app")[links].]

= Admonitions

#note[Useful information that readers should know, even when skimming.]

#tip[Helpful advice for doing things better or more easily.]

#important[Key information users need to know to achieve their goal.]

#warning(title: "Custom title")[Urgent info that needs immediate attention. Titles can be changed.]

#caution[
  Advises about risks or negative outcomes of certain actions.

  Admonitions can hold any content, including `code`, lists, and several paragraphs.
]

= Code

```rust
fn main() {
    let greeting = "Hello from Tola + Typst";
    println!("{greeting}");
}
```

```typst
#let double(x) = 2 * x
The answer is #double(21).
```

= Maths

Inline maths like $e^(i pi) + 1 = 0$ is rendered as MathML, as is display maths:

$ integral_0^infinity e^(-x^2) dif x = sqrt(pi) / 2 $

= Tables

#table(
  columns: 3,
  table.header[Name][Kind][Notes],
  [Tola], [Static site generator], [Builds this site],
  [Typst], [Typesetting language], [What posts are written in],
)

== Tables from data

Data files next to the post can be loaded with `csv`, `json`, `yaml`, `toml` or `read`. They are
inputs only, never published:

#csv-table(csv("languages.csv"))

Or work with the rows directly:

#let langs = csv("languages.csv", row-type: dictionary)
The oldest language listed is #langs.sorted(key: l => int(l.at("First appeared"))).first().Language.

= Citations

Cite entries from a `.bib` (or Hayagriva `.yml`) file with `@key`, like @knuth1984, or with a page
supplement @sicp[p.~42]. The bibliography is rendered wherever `#bibliography(...)` is placed; this
post puts it at the very end.

= Images

Put image files in `static/web-assets/images/` and show them with `asset-image` and their
`/assets/...` URL. The web page loads the published file and the PDF embeds it:

#asset-image("/assets/images/logo.svg", alt: "The site logo", width: 120, height: 120)

= Collapsible sections

`details` folds content away on the web page; the PDF always shows it open:

#details[Click to expand][
  Hidden content.
]

#bibliography("refs.bib", title: "References")
