# Changelog

<!-- markdownlint-configure-file { "MD024": { "siblings_only": true } } -->

## [0.3.0] - 2026-11-08

### Added

- `rake docs:demo` — captures the checked-in illustrative overview as
  animated AVIF + WebP + static PNG (headless Chrome + ffmpeg + img2webp;
  build-host tools), embedded in README via `<picture>`. Examples are
  schematic, not generated from a live Jekyll build; the sequence opens
  with a wireframe strip of the four layout shells.
- `rake docs:layouts` — real per-shell screenshots (sidebar-left,
  sidebar-right, topnav, bare) captured from live demo builds with
  headless Chrome, embedded as a gallery in the README Layouts section;
  the stills are also encoded into an animated
  `layout-demo.{avif,webp,png}` cycling the four shells.
- just-the-docs migration parity (all documented in README):
  - `layout: home`, `page` and `post` aliases of `default`; `{% seo %}`
    meta tags via the new `jekyll-seo-tag` runtime dependency; callout
    classes `.note .new .important .warning .highlight` in theme CSS.
  - `NavGenerator` precomputes the nav tree into
    `site.data["flow_nav"]` once per build (`theme:`-only consumers
    keep the Liquid fallback; `flow.nav_cache: false` opts out), with
    JTD ordering — `nav_order` first, then natural title sort — and
    `child_nav_order: reversed|desc|descending` on parents.
  - Breadcrumbs above content (`flow.breadcrumbs` site-wide,
    `breadcrumbs: false` per page) and an auto children TOC
    (`flow.children_toc`, `has_children: false`, `has_toc: false`).
  - `aux_links` + `aux_links_new_tab` in the topnav navbar-end and the
    sidebar top bar; `nav_external_links` appended to the sidebar nav
    (`title`/`url`/`opens_in_new_tab`/`hide_icon`).
  - `flow.back_to_top` floating button, `flow.theme: light|dark`
    `data-theme` attribute, `nav_enabled: false` → `bare` shell,
    `favicon_ico:` fallback, `table_wrap` `.table-container` wrapping
    and a skip-to-main link.
  - Footer "Page last modified" from `last_modified_at` /
    `last_modified` / `last_modified_date` front matter, controlled by
    `flow.last_edit` / `flow.last_edit_format` plus the JTD aliases
    `last_edit_timestamp` / `last_edit_time_format`.
  - Empty include override hooks: `head_custom`, `header_custom`,
    `footer_custom`, `nav_footer_custom`, `search_placeholder_custom`
    and `toc_heading_custom` — site files win, matching the JTD
    convention.

### Changed

- The no-JS search form `action` now follows
  `client_search.dropdown.redirect_url` instead of hardcoding
  `/search/`.
- In-range gem updates: `addressable` 2.9.1 → 2.9.2, `minitest`
  6.0.6 → 6.1.0, `sass-embedded` 1.107.1 → 1.108.1;
  `BUNDLED WITH` 4.0.21 → 4.0.24.
- CI: `ruby/setup-ruby` pin bumped v1.335.0 → v1.338.0.

### Fixed

- Escape `footer_content` before rendering so config text cannot inject
  HTML; use the trusted `footer_custom.html` include for markup.
- Apply `relative_url` to `nav_external_links` so local links respect
  the site's `baseurl` while absolute external URLs remain unchanged.
- Give navbar burger buttons a visible "Menu" label and preserve their
  four decorative bars for Bulma's burger styling.
- Mark the live-search input as a combobox and expose the results popup
  as a named listbox while keeping its result list compatible with
  jekyll-client-search.

## [0.2.0] - 2026-10-31

### Fixed

- Archived posts and collection documents are now excluded from
  `sitemap.xml` and get `noindex` too — the archive hook moved from
  `:pages, :post_init` to a `:site, :post_read` sweep over
  `site.pages + site.documents` (document `:post_init` fires before
  front matter is merged, so `layout: archive` was invisible there).
- Demo `_config.yml` now excludes `jekyll-theme-flow.gemspec` from
  `_site` — a stale generated copy made Bundler resolve the path gem
  from `_site/` instead of the repo root.

### Changed

- Test suite migrated from RSpec to Minitest (`spec/` → `test/`,
  jekyll-test-harness `framework: :minitest`); coverage, codecov and
  sonar wiring updated accordingly.
- CI matrix now includes a non-blocking Ruby 4.0 leg alongside
  3.3/3.4; `.ruby-version` remains 3.4.12.
- Dependency updates: jekyll-client-search 0.4.0,
  jekyll-icon-flow 0.1.2, rubocop 1.92.2, sass-embedded 1.107.1,
  plus transitive bumps; development dep `rspec` replaced by
  `minitest ~> 6.0`.
- README gained an Inspiration section (just-the-docs nav model;
  planned `layout: portfolio` one-pager after jamigibbs/phantom).
- Version now lives in `lib/jekyll/theme_flow/version.rb`
  (`Jekyll::ThemeFlow::VERSION`), matching the sibling-plugin
  convention; `version:bump` rewrites the constant.
- Updated vendored Bulma Sass conditional syntax to avoid deprecation
  warnings with current Sass.
- Constrained runtime plugin dependencies to compatible version series,
  avoiding open-ended gemspec warnings.
- CI: Semgrep moved from inline `pip3 install semgrep==1.176.0` pins in `ci.yml` and `release.yml` to hashed `.github/requirements-ci.txt` (compiled from `requirements-ci.in`, Python 3.12), installed with `--require-hashes`. Bumped Semgrep to 1.180.0. Added `.github/dependabot.yml` covering github-actions, bundler, and the new `/.github` pip requirements.

## [0.1.1] - 2026-10-06

### Fixed

- `LICENSE.txt` now contains the verbatim AGPL-3.0 text (was a stub);
  added the missing README license section.

### Added

- SimpleCov coverage instrumentation matching the fleet pattern:
  `lib/**/*.rb` tracked, Cobertura formatter and a 90% floor on CI,
  skippable via `COVERAGE=false`. Current suite covers 100% of the
  theme's Ruby lib (13/13 lines).

## [0.1.0] - 2026-10-04

- Bulma and Alpine.js theme with sidebar-left, sidebar-right, topnav and bare layouts.
- Navigation, search and icon integration with jekyll-client-search and jekyll-icon-flow.
- Real Jekyll consumer-site integration tests and Ruby 3.3/3.4 CI.
- Escape site and page metadata, keep theme controls on Lucide, and provide a search form fallback.
- Archive support: `archive` and `archive-index` layouts, `archive_versions` include,
  automatic `noindex` for archived/`noindex: true` pages, and a documented
  scoped-defaults convention for sitemap exclusion.
- Navigation: `is-active` on the current item and its direct parent in the sidebar
  tree and topnav dropdown; optional `icon:` front matter rendered in both branches.
- Theme lib (`lib/jekyll-theme-flow.rb`): bundling `jekyll-sitemap` as a runtime
  dependency (auto-loaded with the theme), a `flow.sitemap` disable switch, and a
  hook that excludes archived pages from sitemap.xml when the theme is plugin-loaded.
- Config defaults injection: plugin-loaded consumers get `sass.quiet_deps: true`
  (silences vendored Bulma deprecation warnings) unless they set it themselves.
