// Post cards and the generated blog index.

#import "@tola/address:0.0.0": asset-url, output-url
#import "@tola/site:0.0.0": site
#import "@preview/wordometer:0.1.6": word-count-of
#import "layout.typ": format-date, shell

/// Average adult silent-reading speed, in words per minute.
#let words-per-minute = 220

/// Words in a post's body, not counting code blocks (inline code still counts) or anything
/// wordometer skips by default (maths, citations, images). Text produced inside `context`, such
/// as components built on `by-target`, is opaque and goes uncounted.
#let post-word-count(post) = word-count-of(
  include post.source.file,
  exclude: (raw.where(block: true),),
).words

/// " · N min read" for a post (at least one minute), to follow its date. Nothing for an empty
/// post, such as a draft stub.
#let read-time(post) = {
  let words = post-word-count(post)
  if words == 0 { return none }
  let minutes = calc.max(1, calc.round(words / words-per-minute))
  [ · #html.span(class: "read-time", title: str(words) + " words")[#minutes min read]]
}

#let post-card(post) = {
  let meta = post.source.meta
  html.li[
    #html.a(href: output-url(post.output))[
      #if meta.hero != none {
        html.img(src: asset-url(meta.hero), alt: "", width: 720, height: 360)
      } else {
        html.div(class: "placeholder", aria-hidden: true)[]
      }
      #html.h3(class: "card-title")[
        #meta.title
        #if meta.draft { html.span(class: "draft-badge")[Draft] }
      ]
      #html.p(class: "date")[#format-date(meta.date)#read-time(post)]
      #if meta.description != none and meta.description != site.description {
        html.p(class: "description")[#meta.description]
      }
    ]
  ]
}

/// A grid of post cards. With `featured`, the first card spans the whole row.
#let post-list(posts, featured: true) = {
  html.ul(class: if featured { "post-grid featured" } else { "post-grid" })[
    #for post in posts { post-card(post) }
  ]
}

/// The `/blog/` index: every post, newest first.
#let blog-index(posts) = {
  shell(
    "blog/index.html",
    "Blog",
    description: "Every post on " + site.title + ".",
    body-class: "blog",
  )[
    #html.h1(class: "page-title")[Blog]
    #if posts.len() == 0 {
      html.p(class: "empty")[Nothing here yet. Check back soon!]
    } else {
      post-list(posts)
    }
  ]
}
