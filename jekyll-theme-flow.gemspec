# frozen_string_literal: true

require_relative "lib/jekyll/theme_flow/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-theme-flow"
  spec.version       = Jekyll::ThemeFlow::VERSION
  spec.authors       = ["Svend Gundestrup"]
  spec.email         = ["svend@gundestrup.dk"]

  spec.summary       = "A Bulma + Alpine.js Jekyll theme with switchable standard layouts"
  # NOTE: rubygems.org renders the description through RDoc::Markup only
  # when it starts with an == heading at column 0 — keep the heredoc
  # content flush-left or the page renders as one plain <p>.
  spec.description   = <<~DESC
    == Bulma + Alpine.js Jekyll theme

    Switchable standard layouts, bundling jekyll-client-search,
    jekyll-icon-flow, jekyll-seo-tag and jekyll-sitemap.
  DESC
  spec.homepage      = "https://github.com/gundestrup/jekyll-theme-flow"
  spec.license       = "AGPL-3.0-or-later"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"

  spec.files = Dir["assets/**/*", "lib/**/*", "_includes/**/*", "_layouts/**/*", "_sass/**/*",
                   "CHANGELOG.md", "LICENSE.txt", "README.md"].select { |path| File.file?(path) }

  spec.required_ruby_version = ">= 3.3"

  spec.add_dependency "jekyll", ">= 4.3", "< 5.0"
  spec.add_dependency "jekyll-client-search", "~> 0.3", ">= 0.3.4"
  spec.add_dependency "jekyll-icon-flow", "~> 0.1"
  spec.add_dependency "jekyll-seo-tag", ">= 2.0", "< 3.0"
  spec.add_dependency "jekyll-sitemap", ">= 1.4", "< 2.0"
end
