# jekyll-theme-flow

A Jekyll theme built on [Bulma](https://bulma.io) (CSS) and
[Alpine.js](https://alpinejs.dev) (interactivity), offering several
standard layout shells you can switch per site or per page.

No Node toolchain required — Bulma compiles through Jekyll's own Sass
pipeline, and Alpine is vendored into the theme.

## Layouts

Set a site-wide default in `_config.yml`:

```yaml
flow:
  layout: sidebar-left   # sidebar-left | sidebar-right | topnav | bare
```

Or per page via front matter:

```yaml
layout: default
flow_layout: topnav      # overrides the site default for this page
```

Named layouts (`sidebar-left`, `sidebar-right`, `topnav`, `bare`) also
work directly in front matter.

| Shell | What you get |
|---|---|
| `sidebar-left` | Sticky left sidebar with expandable nav tree + content column (default) |
| `sidebar-right` | Same, sidebar on the right |
| `topnav` | Bulma navbar with hover dropdowns for children, no sidebar |
| `bare` | Content only — no nav chrome |

On mobile, sidebars collapse into a burger-toggled drawer (Alpine).

## Navigation model

The nav tree is driven by front matter — same convention as
just-the-docs:

```yaml
title: Child Page
parent: Section      # title of the parent page
nav_order: 3         # optional ordering
nav_exclude: true    # optional: hide from nav
```

`grand_parent:` is honoured for auto-opening the tree on grandchildren.
The current page's branch opens automatically; parents get a chevron
toggle.

## Search (jekyll-client-search)

The theme integrates
[jekyll-client-search](https://github.com/gundestrup/jekyll-client-search)
(a runtime dependency — it's pulled in automatically). Enable it:

```yaml
client_search:
  enabled: true
  engine: minisearch        # or elasticlunr / semantic
  collections: [posts]      # and/or include_pages: true
  dropdown:
    enabled: true
    redirect_url: /search/
```

When enabled:

- **sidebar layouts** render a search bar in a top bar above the content
- **topnav** renders a smaller search field on the right of the navbar
- **bare** renders no search chrome
- a `/search/` page ships with the theme (override it by adding your own
  `search.md`)

All `client_search` options (fuzzy MiniSearch, Ollama embeddings, related
results, …) work as documented in the gem.

## Icons

The theme vendors two icon packs under `_includes/icons/` and renders them
inline so they scale with `font-size` and inherit `currentColor`:

- **lucide** (ISC) — UI icons; also used for the theme's own chrome
  (nav chevron, search icon). 29 icons: `menu`, `search`, `x`,
  `chevron-*`, `home`, `file-text`, `folder`, `copy`, `check`,
  `external-link`, `arrow-*`, `download`, `mail`, `rss`, `info`,
  `triangle-alert`, `map`, `map-pin`, `link`, `printer`, `calendar`,
  `tag`, `sun`, `moon`.
- **simple-icons** (CC0) — brand icons: `github`, `x`, `facebook`,
  `instagram`, `youtube`, `mastodon`, `rss`, `bluesky`, `discord`,
  `medium`, `telegram`, `tiktok`, `spotify`.
  (LinkedIn is unavailable — it was removed upstream from simple-icons.)

```liquid
{% include icon.html name="search" %}
{% include icon.html name="github" pack="simple-icons" size="1.5em" %}
```

```yaml
flow:
  icon_pack: lucide      # default pack when pack= is omitted
  icons_enabled: true    # false = icon.html renders nothing (incl. chrome)
```

**Custom icons** (e.g. from [svgrepo.com](https://www.svgrepo.com/) — an
aggregator with no bundleable pack): download the SVG into your site's
`_includes/icons/custom/<name>.svg`, then
`{% include icon.html name="<name>" pack="custom" %}`. Site includes
override theme includes, so you can also shadow a vendored icon by using
the same path.

To use more lucide/simple-icons than the vendored subset, drop additional
SVGs into `_includes/icons/<pack>/` in your site the same way.

## Other config

```yaml
flow:
  layout: sidebar-left
  logo: /assets/logo.svg         # brand icon next to site.title (all pages)
  logo_enabled: true             # set false to hide without removing logo
  favicon: /assets/favicon.ico   # <link rel="icon">
  favicon_enabled: true          # set false to disable
  search_placeholder: "Search"   # placeholder text in the search field
  icon_pack: lucide              # lucide | simple-icons | custom
  icons_enabled: true            # master switch for {% include icon.html %}
  footer_text: "Powered by ..."  # optional footer line
```

## Customization surface

Intentionally small — the theme relies on Bulma components and helpers
(`menu`, `navbar`, `columns`, `is-hidden-*`, spacing helpers) rather
than bespoke CSS. The only custom CSS is the app shell (~50 lines in
`_sass/flow.scss`): fixed/sticky sidebar, drawer positioning, chevron
rotation, brand icon sizing.

Override the usual Jekyll way: same-named files in your site win
(`_includes/`, `_layouts/`, `_sass/`). Bulma Sass variables can be
re-themed via `@use "bulma" with (...)`.

## Development

```bash
bundle install
bundle exec jekyll serve   # demo pages in repo root
```

Known upstream noise: Bulma 1.0.x emits a handful of Sass `if()`
deprecation warnings during build — harmless, fixed upstream eventually.
