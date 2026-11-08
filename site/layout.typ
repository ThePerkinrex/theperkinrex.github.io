// The HTML shell every document shares: head, header, footer.

#import "@tola/address:0.0.0": asset-url, output-url
#import "@tola/code:0.0.0": code-stylesheet
#import "@tola/site:0.0.0": site
#import "seo.typ": head-entries
#import "selection.typ": build-info

#let github-url = "https://github.com/ThePerkinrex"

/// The main navigation: (label, output) pairs. The active one is chosen by output prefix.
#let nav-items = (
  ("Home", "index.html"),
  ("Blog", "blog/index.html"),
  ("About", "about/index.html"),
)

#let github-icon = html.elem(
  "svg",
  attrs: (viewBox: "0 0 16 16", width: "24", height: "24", "aria-hidden": "true"),
  html.elem("path", attrs: (
    fill: "currentColor",
    d: "M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.012 8.012 0 0 0 16 8c0-4.42-3.58-8-8-8z",
  )),
)

#let rss-icon = html.elem(
  "svg",
  attrs: (viewBox: "0 0 16 16", width: "24", height: "24", "aria-hidden": "true"),
  html.elem("path", attrs: (
    fill: "currentColor",
    d: "M2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2zm1.5 2.5c5.523 0 10 4.477 10 10a1 1 0 1 1-2 0 8 8 0 0 0-8-8 1 1 0 0 1 0-2zm0 4a6 6 0 0 1 6 6 1 1 0 1 1-2 0 4 4 0 0 0-4-4 1 1 0 0 1 0-2zm.5 7a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3z",
  )),
)

#import "components.typ": icon

#let sun-icon = icon(
  html.elem("circle", attrs: (cx: "12", cy: "12", r: "4")),
  "M12 2v2",
  "M12 20v2",
  "m4.93 4.93 1.41 1.41",
  "m17.66 17.66 1.41 1.41",
  "M2 12h2",
  "M20 12h2",
  "m6.34 17.66-1.41 1.41",
  "m19.07 4.93-1.41 1.41",
)
#let moon-icon = icon("M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z")

/// Runs before the stylesheet applies: picks the stored theme, or the system's.
#let theme-init = "try{var t=localStorage.getItem('theme')}catch(e){}document.documentElement.dataset.theme=t||(matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light')"

#let theme-toggle = html.elem(
  "button",
  attrs: (
    type: "button",
    class: "theme-toggle",
    title: "Toggle dark mode",
    "aria-label": "Dark mode",
    "aria-pressed": "false",
  ),
  {
    sun-icon
    moon-icon
  },
)

#let is-active(item-output, current) = {
  if item-output == "index.html" { current == "index.html" } else {
    current.starts-with(item-output.trim("index.html", at: end))
  }
}

/// The page header. It sticks to the top of the viewport; with `page-title`, that title slides in
/// next to the logo once the page's own `<h1>` has scrolled away (see `scripts/site.js`).
#let site-header(current, page-title: none) = html.header(class: "site-header")[
  #html.nav[
    #html.div(class: "brand-area")[
      #html.a(class: "brand", href: output-url("index.html"))[
        #html.img(src: asset-url("/assets/images/logo.png"), alt: "", width: 36, height: 36)
        #html.span(class: "site-name")[#site.title]
      ]
      #if page-title != none {
        // Duplicates the visible <h1>, so it is hidden from assistive technology.
        html.span(class: "header-title", aria-hidden: true)[#page-title]
      }
    ]
    #html.div(class: "internal-links")[
      #for (label, output) in nav-items {
        if current != none and is-active(output, current) {
          html.a(href: output-url(output), class: "active", aria-current: "page")[#label]
        } else {
          html.a(href: output-url(output))[#label]
        }
      }
    ]
    #html.div(class: "social-links")[
      #theme-toggle
      #html.a(href: output-url("feed.xml"), title: "RSS feed", {
        html.span(class: "sr-only")[RSS feed]
        rss-icon
      })
      #html.a(href: github-url, title: "GitHub", {
        html.span(class: "sr-only")[GitHub: ThePerkinrex]
        github-icon
      })
    ]
  ]
]

#let site-footer() = html.footer(class: "site-footer")[
  #html.p[© #build-info.year Juan Mahou · Built with #html.a(href: "https://tola.build")[Tola] and #html.a(href: "https://typst.app")[Typst]]
]

/// Wrap `body` in the complete page shell and declare it as `output`.
///
/// - output (string): the output file, such as `blog/index.html`.
/// - title (string | content): the document title.
/// - description (none | string | content): the page summary.
/// - page (none | dictionary): the `(source:, output:)` record, when the document has a source.
/// - body-class (string): a class on `<body>` for page-type specific styling.
/// - header-title (none | string | content): shown in the sticky header after the page's `<h1>`
///   scrolls out of view.
#let shell(
  output,
  title,
  description: none,
  page: none,
  body-class: "page",
  header-title: none,
  body,
) = {
  document(output, format: "html", title: title, description: description)[
    #html.html(lang: site.language.tag)[
      #html.head[
        #for entry in head-entries(title, description: description, page: page) { entry }
        #html.script(theme-init)
        #html.script("", src: asset-url("/assets/scripts/site.js"), defer: true)
        #html.link(rel: "icon", type: "image/png", href: asset-url("/assets/images/logo.png"))
        #html.link(
          rel: "alternate",
          type: "application/rss+xml",
          title: site.title,
          href: output-url("feed.xml"),
        )
        #html.link(rel: "stylesheet", href: asset-url("/assets/css/site.css"))
        #code-stylesheet()
      ]
      #html.body(class: body-class)[
        #site-header(output, page-title: header-title)
        #html.main[#body]
        #site-footer()
      ]
    ]
  ]
}

/// Format a native date like "May 24, 2026".
#let format-date(d) = html.time(datetime: d)[
  #d.display("[month repr:short] [day padding:none], [year]")
]
