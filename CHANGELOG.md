# Changelog

## [Unreleased]

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
