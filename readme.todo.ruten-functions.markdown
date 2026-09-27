# TODO — functions learned from rutenskiklub

Candidate theme features extracted from the rutenskiklub site
(bulma-clean-theme + site-owned overrides). Each item below describes
what the site had to build itself — i.e. what a theme should ship.

Reference implementation: `../rutenskiklub` (`_layouts/archive.html`,
`_includes/archive_versions.html`, `_plugins/archive.rb`,
`_includes/head-scripts.html`, `_pages/arkiv.markdown`).

## 1. `layout: archive` — archived/superseded pages

Ship `_layouts/archive.html` in the theme:

- "Arkiveret version" warning banner (Bulma `notification is-warning`)
- Optional `archive_link_current:` front matter → "Se den gældende
  version" link in the banner
- Version footer include (see #2) rendered after `{{ content }}`
- Chains into the appropriate shell (`bare`-ish or `flow_layout`-aware)

## 2. `_includes/archive_versions.html` — version cross-linking

`archive_link_current` is the **join key**: archived pages register
which current page they were superseded by, and Liquid resolves both
directions:

- On an archived page: list the current version + sibling archives
  (other pages with the same `archive_link_current`, excluding self)
- On a current page (`{% include archive_versions.html %}` at the
  bottom of the markdown): list all pages whose
  `archive_link_current == page.url` → "Tidligere versioner"

Archiving a new version then needs zero link maintenance — set the
front matter and every list updates.

## 3. `noindex` robots meta — in `head.html`

The theme owns `<head>`, so this is theme-shippable:

```liquid
{% if page.noindex or page.layout == "archive" %}
<meta name="robots" content="noindex">
{% endif %}
```

`noindex: true` should also work standalone for non-archive pages
(e.g. search page, thank-you pages).

## 4. Sitemap exclusion — theme CANNOT do this alone

jekyll-sitemap reads `page.data["sitemap"]`; a theme gem cannot ship
`_plugins/` (Jekyll only loads `_layouts`, `_includes`, `_sass`,
`assets` from theme gems — gem hooks never run). Options:

- **(a) Site-side companion gem** (like jekyll-client-search): a
  `:pages, :post_init` hook sets `page.data["sitemap"] = false` for
  `layout == "archive"`. Same hook as `archive.rb` in rutenskiklub.
  Cleanest UX but another gem.
- **(b) Convention + `_config.yml` defaults** — if archived sources
  live under a dedicated dir (e.g. `_pages/archive/`), the site can
  scope front-matter defaults: `scope: {path: "_pages/archive"}` →
  `values: {layout: archive, sitemap: false}`. No plugin at all —
  defaults merge into `page.data` where jekyll-sitemap sees them.
- **(c) Document `sitemap: false` as required front matter** —
  simplest, but easy to forget.

Note scope (a): the hook must also cover `posts`/`documents`
containers if archiving non-page content should work.

## 5. `/archive/` index page

Themes can't ship root pages — ship an `archive-index` **layout**
instead that lists `site.pages | where: "layout", "archive"` sorted
by `archive_link_current`; the site adds a one-line page:

```markdown
---
layout: archive-index
permalink: /archive/
nav_exclude: true
---
```

## 6. Nav: dropdown parent icons + active state

rutenskiklub patched its site-owned `header.html` so the dropdown
branch renders the parent's lucide icon (the flat branch had it, the
dropdown branch didn't). In flow's `navbar.html`/`nav_tree.html`:
ensure parent items keep their `{% icon %}` in the dropdown path, and
that the parent gets `is-active` when `page.url` matches any
`subitem.link` — not only the parent link itself (needed when child
URLs don't share the parent's prefix).

## 7. General principle: layout front matter ≠ `page.data`

Keys set in a layout's front matter never reach `page.data` —
jekyll-sitemap, `{% seo %}`, and `&lt;head&gt;` includes ignore them
silently. Any "this layout implies X" contract must be implemented
via a plugin hook, `_config.yml` defaults, or head-side checks like
#3 (see engineering-memory
`lessons-learned/jekyll-layout-frontmatter-invisible.md`).
