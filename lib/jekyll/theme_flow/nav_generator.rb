# frozen_string_literal: true

module Jekyll
  module ThemeFlow
    # Builds the whole nav tree once per build into
    # site.data["flow_nav"] = { "roots" => [...], "index" => {...} }.
    #
    # Before this generator, Liquid scanned `site.html_pages` for each
    # nav node on each rendered page. This groups and sorts pages once;
    # Liquid still traverses the tree on each page to emit its menu, but
    # no longer rescans the whole page collection per node. Templates
    # read precomputed children from hashes:
    # `p.children` on a node hash is an array, while on a Jekyll::Page
    # drop it is nil, which is what lets the same template fall back
    # to live scans for `theme:`-only consumers (this file only loads
    # via `plugins:` or the :jekyll_plugins Bundler group).
    #
    # Ordering matches the Liquid path exactly: `nav_order` pages
    # first, unordered pages case-insensitive natural sort by title,
    # and a parent may flip its own children with
    # `child_nav_order: reversed|desc|descending`.
    class NavGenerator < Jekyll::Generator
      safe true

      REVERSED = %w[reversed desc descending].freeze
      MAX_DEPTH = 8
      NUMBERED_PART = /(\d+)/

      def generate(site)
        # Escape hatch: flow.nav_cache: false keeps the Liquid fallback.
        return if site.config.dig("flow", "nav_cache") == false

        by_parent = nav_pages(site).group_by { |page| page.data["parent"] }
        roots = build_level(by_parent[nil], nil, by_parent)
        index = {}
        index_level(roots, index)
        site.data["flow_nav"] = { "roots" => roots, "index" => index }
      end

      # `site.html_pages` is Liquid-only — this is the Ruby equivalent.
      def nav_pages(site)
        site.pages.select do |page|
          page.html? && page.data["title"] && page.data["nav_exclude"] != true
        end
      end

      private

      def build_level(kids, parent_page, by_parent, depth = 0)
        return [] if depth > MAX_DEPTH

        kids = sort_level(kids || [])
        kids.reverse! if reversed?(parent_page)
        kids.map { |child| node_for(child, by_parent, depth) }
      end

      def reversed?(page)
        page && REVERSED.include?(page.data["child_nav_order"])
      end

      def node_for(child, by_parent, depth)
        {
          "title" => child.data["title"],
          "url" => child.url,
          "icon" => child.data["icon"],
          "parent" => child.data["parent"],
          "children" => build_level(by_parent[child.data["title"]], child, by_parent, depth + 1)
        }
      end

      def sort_level(list)
        ordered, unordered = list.partition { |page| page.data["nav_order"] }
        ordered.sort_by! { |page| page.data["nav_order"] }
        unordered.sort_by! { |page| natural_key(page.data["title"]) }
        ordered + unordered
      end

      # Case-insensitive natural sort key matching Liquid's
      # sort_natural: "Section 2" < "Section 10".
      def natural_key(title)
        title.to_s.downcase.split(NUMBERED_PART).map do |part|
          part.match?(/\A\d+\z/) ? [0, part.to_i] : [1, part]
        end
      end

      def index_level(nodes, index)
        nodes.each do |node|
          index[node["title"]] ||= node
          index_level(node["children"], index)
        end
      end
    end
  end
end
