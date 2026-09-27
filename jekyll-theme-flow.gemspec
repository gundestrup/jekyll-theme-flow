# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "jekyll-theme-flow"
  spec.version       = "0.1.0"
  spec.authors       = ["Svend Gundestrup"]
  spec.email         = ["svend@gundestrup.dk"]

  spec.summary       = "A Bulma + Alpine.js Jekyll theme with switchable standard layouts"
  spec.homepage      = "https://github.com/gundestrup/jekyll-theme-flow"
  spec.license       = "AGPL-3.0-or-later"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = `git ls-files -z`.split("\x0").grep(
    /\A(?:assets|_includes|_layouts|_sass|search\.md|LICENSE|README)/i
  )

  spec.required_ruby_version = ">= 3.3"

  spec.add_dependency "jekyll", ">= 4.3", "< 5.0"
  spec.add_dependency "jekyll-client-search", ">= 0.3.4"
  spec.add_dependency "jekyll-icon-flow", ">= 0.1"
end
