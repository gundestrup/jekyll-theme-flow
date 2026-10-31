# Changelog

## [0.2.0] - 2026-10-31

### Fixed

- Archived posts and collection documents are now excluded from
  `sitemap.xml` and get `noindex` too — the archive hook moved from
  `:pages, :post_init` to a `:site, :post_read` sweep over
  `site.pages + site.documents` (document `:post_init` fires before
  front matter is merged, so `layout: archive` was invisible there).

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
