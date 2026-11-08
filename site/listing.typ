// Post cards and the generated blog index.

#import "@tola/address:0.0.0": asset-url, output-url
#import "@tola/site:0.0.0": site
#import "layout.typ": format-date, shell

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
      #html.p(class: "date")[#format-date(meta.date)]
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
