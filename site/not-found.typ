#import "@tola/address:0.0.0": output-url
#import "layout.typ": shell

/// Write `404.html`, the page shown for an address the site does not publish.
#let not-found-template() = {
  shell("404.html", "Page not found", body-class: "not-found")[
    #html.div(class: "prose")[
      #html.h1[404]
      #html.p[The page you requested could not be found.]
      #html.p[#html.a(href: output-url("index.html"))[← Back home]]
    ]
  ]
}
