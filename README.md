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

## Other config

```yaml
flow:
  layout: sidebar-left
  logo: /assets/logo.svg        # optional, rendered beside site.title
  footer_text: "Powered by ..." # optional footer line
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
