// Page metadata: every field a source may pass to `tola-meta`. Unknown fields are errors.

#import "@tola/schema:0.0.0": (
  date, describe, literal, nullable, one-or-many, optional, schema, timestamp, trim, union,
  url-path,
)
#import "@tola/site:0.0.0": site

/// One page author: a `name`, with an optional `email` and `url`.
#let author = schema(
  (
    name: str,
    email: optional(nullable(str)),
    url: optional(nullable(str)),
  ),
  unknown: "keep",
)

#let page-schema = schema((
  title: describe(
    optional(nullable(union(trim(str), content)), default: site.title),
    "the page title, shown in the browser tab and in lists",
  ),
  description: describe(
    optional(nullable(union(trim(str), content)), default: site.description),
    "the page summary, shown under the title in post lists and in link previews",
  ),
  authors: describe(
    optional(nullable(one-or-many(union(str, author))), default: site.authors),
    "who wrote the page: a name, or a dictionary with name, email, and url",
  ),
  tags: describe(
    optional(one-or-many(str), default: ()),
    "the topics this page belongs to",
  ),
  draft: describe(
    optional(bool, default: false),
    "keeps the page out of the published site",
  ),
  permalink: describe(
    optional(nullable(url-path), default: none),
    "overrides the file-based route: `/about/` is a directory, `/about.html` is a file",
  ),
  date: describe(
    optional(nullable(date), default: none),
    "the publication day (`YYYY-MM-DD`); required for blog posts",
  ),
  updated: describe(
    optional(nullable(date), default: none),
    "the day of the last meaningful change, shown under the title",
  ),
  hero: describe(
    optional(nullable(str), default: none),
    "a 2:1 banner for posts, preferably SVG: an `/assets/images/...` URL",
  ),
  feed: describe(
    optional(bool, default: true),
    "includes the post in feed.xml",
  ),
  sitemap: describe(
    optional(bool, default: true),
    "includes the page in sitemap.xml",
  ),
))
