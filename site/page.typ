#import "@tola/address:0.0.0": asset-url, output-url
#import "@tola/code:0.0.0": code-themes, render-code
#import "layout.typ": format-date, shell
#import "listing.typ": post-list, read-time
#import "selection.typ": is-post, pdf-output
#import "components.typ": code-options, icon, line-number, line-number-digits
#import "@tola/document:0.0.0": current-document

/// Typst's own footnote placement is unavailable inside a custom `<html>` shell, so references
/// become superscript links and the notes are listed after the body.
#let footnote-ref(it) = context {
  let n = str(counter(footnote).get().first())
  // `role` has no typed parameter on `html.a`.
  html.sup(class: "footnote-ref", html.elem("a", attrs: (
    href: "#fn-" + n,
    id: "fnref-" + n,
    role: "doc-noteref",
  ))[#n])
}

#let footnote-list() = context {
  let notes = query(selector(footnote).within(current-document().location))
  if notes.len() > 0 {
    html.elem("section", attrs: (class: "footnotes", role: "doc-endnotes"))[
      #html.ol[
        #for (i, note) in notes.enumerate() {
          let n = str(i + 1)
          html.li(id: "fn-" + n)[
            #note.body
            #html.elem("a", attrs: (
              href: "#fnref-" + n,
              role: "doc-backlink",
              "aria-label": "Back to text",
            ))[↩]
          ]
        }
      ]
    ]
  }
}

/// Rules every source body is rendered with.
#let content-rules(body) = context {
  // `outline()` and the like query the whole site Bundle; keep them to this page's headings.
  set outline(target: selector(heading).within(current-document().location))
  set raw(theme: code-themes.github)
  show raw: render-code.with(dark-theme: code-themes.github-dark)
  // Numbered blocks: each line becomes a `.line` span carrying its number, which site.css shows.
  show raw.where(block: true): it => context {
    let options = code-options.get()
    if not options.numbers { return it }
    // `data-line` has no typed parameter on `html.span`.
    show raw.line: line => html.elem(
      "span",
      attrs: (class: "line", "data-line": str(line-number(line, options))),
      line.body,
    )
    render-code(
      it,
      dark-theme: code-themes.github-dark,
      attrs: (class: "numbered", style: "--line-digits: " + str(line-number-digits(it, options))),
    )
  }
  show footnote: footnote-ref
  // Wide tables scroll inside their own box instead of widening the page on phones.
  show table: it => html.div(class: "table-scroll", it)
  body
  footnote-list()
}

#let draft-badge = html.span(class: "draft-badge")[Draft]

#let download-icon = icon("M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4", "m7 10 5 5 5-5", "M12 15V3")

/// A blog post: hero image, date, title, description, then the body.
#let post-template(page) = {
  let meta = page.source.meta
  shell(
    page.output,
    meta.title,
    description: meta.description,
    page: page,
    body-class: "post",
    header-title: meta.title,
  )[
    #html.article[
      #if meta.hero != none {
        html.div(class: "hero-image")[
          #html.img(src: asset-url(meta.hero), alt: "", width: 1020, height: 510)
        ]
      }
      #html.div(class: "prose")[
        #html.div(class: "title")[
          #html.div(class: "date")[
            #format-date(meta.date)#read-time(page)
            #if meta.updated != none {
              html.div(class: "last-updated-on")[Last updated on #format-date(meta.updated)]
            }
          ]
          #if meta.draft { draft-badge }
          #html.h1[#meta.title]
          #if meta.tags.len() > 0 {
            html.ul(class: "tags")[#for tag in meta.tags { html.li[#tag] }]
          }
          // The same post typeset for paper (site/print.typ).
          #let pdf = pdf-output(page)
          #html.a(class: "pdf-download", href: output-url(pdf), download: pdf.split("/").last())[
            #download-icon
            #html.span[Download PDF]
          ]
          #html.hr()
        ]
        #html.div(id: "post-body")[#content-rules(include page.source.file)]
        #html.p(class: "back")[#html.a(href: output-url("blog/index.html"))[← All posts]]
      ]
    ]
  ]
}

/// An ordinary page, such as About. The source writes its own `#title()`.
#let plain-template(page) = {
  let meta = page.source.meta
  shell(page.output, meta.title, description: meta.description, page: page)[
    #html.div(class: "prose")[
      #if meta.draft { draft-badge }
      #content-rules(include page.source.file)
    ]
  ]
}

/// The home page: the source's introduction followed by the most recent posts.
#let home-template(page, posts, shown: 5) = {
  let meta = page.source.meta
  shell(page.output, meta.title, description: meta.description, page: page, body-class: "home")[
    #html.div(class: "prose")[#content-rules(include page.source.file)]
    #if posts.len() > 0 {
      html.section(class: "recent")[
        #html.h2[Recent posts]
        #post-list(posts.slice(0, calc.min(shown, posts.len())), featured: false)
        #if posts.len() > shown {
          html.p[#html.a(href: output-url("blog/index.html"))[All posts →]]
        }
      ]
    }
  ]
}

/// Render one selected page with the template its kind calls for.
#let page-template(page, posts) = {
  if page.output == "index.html" {
    home-template(page, posts)
  } else if is-post(page.source) {
    post-template(page)
  } else {
    plain-template(page)
  }
}
