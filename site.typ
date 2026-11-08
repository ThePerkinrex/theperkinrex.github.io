#import "@tola/site:0.0.0": site
#import "@tola/source:0.0.0": all-sources
#import "site/selection.typ": select-pages, select-posts
#import "site/page.typ": page-template
#import "site/print.typ": post-pdf
#import "site/listing.typ": blog-index
#import "site/not-found.typ": not-found-template
#import "site/seo.typ": feed-output, sitemap-output

#set text(
  lang: site.language.lang,
  script: site.language.script,
  region: site.language.region,
)
// Counters are global across the whole build; number each page's (and PDF's) bibliography on its
// own instead of continuing from the previous one.
#set bibliography(group: none)

/// Every page this site publishes, paired with its output file.
#let pages = select-pages(all-sources())
/// The blog posts among them, newest first.
#let posts = select-posts(pages)

#for page in pages { page-template(page, posts) }
// A downloadable PDF of every post, linked from the post page.
#for post in posts { post-pdf(post) }

#blog-index(posts)
#not-found-template()
#feed-output("feed.xml", posts)
#sitemap-output("sitemap.xml", pages, extra: ("blog/index.html",))
