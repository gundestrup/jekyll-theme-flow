# TODO — functions learned from rutenskiklub — COMPLETE ✅

**Status:** items 1, 2, 3, 5, 6 implemented in the theme
(`_layouts/archive.html`, `_layouts/archive-index.html`,
`_includes/archive_versions.html`, `noindex` in `head.html`, navbar +
nav_tree `is-active`/icons). Item 4 resolved via option (a) — built
into the theme: `jekyll-sitemap` is a runtime dependency (auto-loaded by
Jekyll's theme-deps mechanism), and `lib/jekyll-theme-flow.rb` ships a
`:site, :post_read` hook sweeping pages, posts and collection documents
to exclude `layout: archive` content when the theme is plugin-loaded
(`plugins:` list / `:jekyll_plugins` group), plus a `flow.sitemap`
disable switch. Scoped defaults (option b) remain
documented for `theme:`-only consumers.
Item 7 respected: contracts live in head-side checks and config
defaults, never layout front matter.
Item 8 moved to README.md as a planned feature — the phantom
inspiration link lives there now; local reference remains
`../anders_korsgaard` + `../borg-collective.eu`.

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

Note scope (a): resolved — a single `:site, :post_read` hook sweeps
`site.pages + site.documents` (posts included), so `layout: archive`
posts and collection documents are excluded the same way pages are.
(`:post_init` per-container can't be used for documents: it fires
before front matter is merged into `data`.)

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

## 8. `layout: portfolio` — single-page portfolio/person site

External inspiration: [jamigibbs/phantom](https://github.com/jamigibbs/phantom)
(Bootstrap one-pager). We want the same pattern on our Bulma +
Alpine.js base.

Reference implementations — twin sites that share an in-repo copy of
this layout (copy-paste drift has already bitten once, see their
`AGENTS.md` — extracting to the theme removes the duplication):

- `../anders_korsgaard` — `_layouts/default.html`, `index.html`,
  `_includes/{about,services,contact,social}.md`, `author:` config
- `../borg-collective.eu` — same structure

What the sites built themselves — i.e. what a `portfolio` layout
should ship:

- **Fixed navbar with anchor links** (`#about`, `#services`,
  `#media`, `#contact`) — a `topnav` variant for single-page use;
  Alpine burger toggle instead of the sites' hand-rolled script
- **Hero block**: rounded `site.profile_picture`, `author.title`
  subtitle, social-links row
- **Content sections** via markdownified includes (`about`,
  `services`, `contact`) — theme ships the skeleton + slot includes,
  consumers drop in their own `_includes/*.md` (same pattern as
  `search.md` / `archive-index`)
- **Media/projects cards**: posts rendered as link cards honouring
  `site:`, `git:`, `link:`, `kilde_ikon:` front matter (phantom's
  projects-grid equivalent); `site.posts` loop, optional
  jekyll-paginate for a blog variant
- **Footer**: social links + copyright year-range
  (`footer_copyright_year` → current year)
- **Config contract**: `author.{name,title,url,email,mobile,
  location,social.*}`, `profile_picture`, `footer_copyright_*` —
  decide whether to keep the `author:` keyspace or nest under
  `flow.portfolio.*` (same rule as #7: contracts live in config,
  not layout front matter)
