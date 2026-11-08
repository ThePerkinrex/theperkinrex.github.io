#import "@tola/site:0.0.0": site
#import "@tola/source:0.0.0": all-sources
#import "site/selection.typ": select-pages, select-posts
#import "site/page.typ": page-template
#import "site/listing.typ": blog-index
#import "site/not-found.typ": not-found-template
#import "site/seo.typ": feed-output, sitemap-output

#set text(
  lang: site.language.lang,
  script: site.language.script,
  region: site.language.region,
)

/// Every page this site publishes, paired with its output file.
#let pages = select-pages(all-sources())
/// The blog posts among them, newest first.
#let posts = select-posts(pages)

#for page in pages { page-template(page, posts) }

#blog-index(posts)
#not-found-template()
#feed-output("feed.xml", posts)
#sitemap-output("sitemap.xml", pages, extra: ("blog/index.html",))
