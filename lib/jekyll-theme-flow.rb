# frozen_string_literal: true

require "jekyll"
require "jekyll-sitemap"

# Plugin side of the theme. Layouts/includes work via
# `theme: jekyll-theme-flow` alone; this file is only evaluated when the
# gem is required as a plugin (`plugins:` list or :jekyll_plugins
# Bundler group). The require above runs during Site#setup — early
# enough for the sitemap generator to be instantiated — so sitemap.xml
# works out of the box, and archive pages stay out of it via the hook
# below. Both switches are disable-able:
#
#   flow.sitemap: false                  - drop the sitemap generator
#   flow.archive.sitemap_exclude: false  - keep archived pages in sitemap.xml
#
# It also injects default config keys the user can still override —
# currently `sass.quiet_deps`, which hides deprecation noise from
# vendored Bulma while keeping warnings from site Sass visible.

Jekyll::Hooks.register :site, :after_init do |site|
  sass = (site.config["sass"] ||= {})
  sass["quiet_deps"] = true unless sass.key?("quiet_deps")

  next unless site.config.dig("flow", "sitemap") == false

  site.generators.delete_if do |generator|
    defined?(Jekyll::JekyllSitemap) && generator.instance_of?(Jekyll::JekyllSitemap)
  end
end

Jekyll::Hooks.register :pages, :post_init do |page|
  next unless page.data["layout"] == "archive"
  next if page.site.config.dig("flow", "archive", "sitemap_exclude") == false

  page.data["sitemap"] = false
  page.data["noindex"] = true
end
