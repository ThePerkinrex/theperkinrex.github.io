#import "@tola/source:0.0.0": tola-meta
#import "@tola/address:0.0.0": asset-url

#tola-meta((
  title: "ThePerkinrex",
  description: "Juan Mahou's blog about programming, tech and whatever I happen to be building.",
  sitemap: true,
))

#html.div(class: "intro")[
  #html.img(src: asset-url("/assets/images/logo.png"), alt: "", width: 120, height: 120)
  #html.div[
    #title()
    #html.p(class: "tagline")[Tech-lover & developer]
  ]
]

Welcome! This is where I write about programming, tech and whatever I happen to be building at
the moment. Have a look at the #link("/blog/")[blog], or read a bit #link("/about/")[about me].
