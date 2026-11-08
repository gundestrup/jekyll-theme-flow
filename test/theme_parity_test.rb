# frozen_string_literal: true

require "test_helper"

# Parity features for sites migrating from just-the-docs-style
# conventions: layout aliases, empty include override hooks, {% seo %},
# breadcrumbs, auto children TOCs, nav ordering, aux/external links,
# callouts and the small chrome switches. All asserted against real
# build output.
class ThemeParityTest < Minitest::Test
  def files
    jekyll_files do
      file "index.md" do
        frontmatter("layout" => "home", "title" => "Home", "nav_order" => 1)
        contents "Welcome"
      end
      file "plain.md" do
        frontmatter("layout" => "page", "title" => "Plain")
        contents "Plain page"
      end
      file "section.md" do
        frontmatter("layout" => "default", "title" => "Section", "nav_order" => 2)
        contents "Section page"
      end
      file "child.md" do
        frontmatter("layout" => "default", "title" => "Child", "parent" => "Section")
        contents "Child page"
      end
      file "grandchild.md" do
        frontmatter("layout" => "default", "title" => "Grandchild", "parent" => "Child")
        contents "Grandchild page"
      end
      file "sorter.md" do
        frontmatter("layout" => "default", "title" => "SortSection", "nav_order" => 3)
        contents "Sort parent"
      end
      file "zebra.md" do
        frontmatter("layout" => "default", "title" => "Zebra", "parent" => "SortSection")
        contents "z"
      end
      file "alpha.md" do
        frontmatter("layout" => "default", "title" => "Alpha", "parent" => "SortSection")
        contents "a"
      end
      file "ordered.md" do
        frontmatter("layout" => "default", "title" => "Ordered",
                    "parent" => "SortSection", "nav_order" => 1)
        contents "o"
      end
      file "revparent.md" do
        frontmatter("layout" => "default", "title" => "Reversed",
                    "child_nav_order" => "reversed", "nav_order" => 4)
        contents "Reversed parent"
      end
      file "rev-a.md" do
        frontmatter("layout" => "default", "title" => "RevA", "parent" => "Reversed")
        contents "a"
      end
      file "rev-z.md" do
        frontmatter("layout" => "default", "title" => "RevZ", "parent" => "Reversed")
        contents "z"
      end
      file "no-toc.md" do
        frontmatter("layout" => "default", "title" => "NoTOC",
                    "has_toc" => false, "nav_exclude" => true)
        contents "No toc here"
      end
      file "no-toc-child.md" do
        frontmatter("layout" => "default", "title" => "NoTOCChild",
                    "parent" => "NoTOC", "nav_exclude" => true)
        contents "child"
      end
      file "hidden.md" do
        frontmatter("layout" => "default", "title" => "Hidden",
                    "nav_enabled" => false, "nav_exclude" => true)
        contents "No chrome"
      end
      file "dated.md" do
        frontmatter("layout" => "default", "title" => "Dated",
                    "last_modified" => "2026-01-02", "nav_exclude" => true)
        contents "Old"
      end
      file "dated2.md" do
        frontmatter("layout" => "default", "title" => "Dated2",
                    "last_modified_date" => "2026-03-04", "nav_exclude" => true)
        contents "Older"
      end
      file "blog.md" do
        frontmatter("layout" => "post", "title" => "Blog", "nav_exclude" => true)
        contents "Post page"
      end
      file "descparent.md" do
        frontmatter("layout" => "default", "title" => "DescParent",
                    "child_nav_order" => "descending", "nav_order" => 5)
        contents "Descending parent"
      end
      file "desc-a.md" do
        frontmatter("layout" => "default", "title" => "DescA", "parent" => "DescParent")
        contents "a"
      end
      file "desc-z.md" do
        frontmatter("layout" => "default", "title" => "DescZ", "parent" => "DescParent")
        contents "z"
      end
      file "unsafe-parent.md" do
        frontmatter("layout" => "default", "title" => '<img src=x onerror="alert(1)">',
                    "nav_exclude" => true)
        contents "unsafe parent"
      end
      file "unsafe-child.md" do
        frontmatter("layout" => "default", "title" => "SafeChild",
                    "parent" => '<img src=x onerror="alert(1)">', "nav_exclude" => true)
        contents "safe child"
      end
      file "_includes/header_custom.html" do
        contents '<span class="x-header-marker">H</span>'
      end
      file "_includes/toc_heading_custom.html" do
        contents '<h2 class="title is-6">Custom contents</h2>'
      end
      file "_includes/search_placeholder_custom.html" do
        contents "Søg i arkivet"
      end
      file "top.md" do
        frontmatter("layout" => "topnav", "title" => "TopNav", "nav_order" => 6)
        contents "Topnav page"
      end
      file "_includes/head_custom.html" do
        contents '<meta name="x-head-marker" content="1">'
      end
      file "_includes/nav_footer_custom.html" do
        contents '<span class="x-nav-footer">site credit</span>'
      end
      file "_includes/footer_custom.html" do
        contents '<span class="x-footer">extra footer</span>'
      end
    end
  end

  def config
    {
      "title" => "Parity Site",
      "url" => "http://example.test",
      "theme" => "jekyll-theme-flow",
      "plugins" => %w[jekyll-client-search jekyll-icon-flow jekyll-theme-flow],
      "flow" => { "layout" => "sidebar-left" },
      "client_search" => {
        "enabled" => true,
        "engine" => "minisearch",
        "include_pages" => true,
        "dropdown" => { "enabled" => true, "redirect_url" => "/soeg/" }
      },
      "aux_links" => { "Source" => "https://example.com/src" },
      "aux_links_new_tab" => true,
      "nav_external_links" => [
        { "title" => "Club", "url" => "https://example.com/club", "opens_in_new_tab" => true }
      ],
      "favicon_ico" => "/icons/parity.ico",
      "footer_content" => "Built with tests",
      "last_edit_timestamp" => true,
      "last_edit_time_format" => "%Y"
    }
  end

  def page(site, url)
    site.pages.find { |p| p.url == url }.output
  end

  def nav_section(html)
    start = html.index('aria-label="site navigation"')
    finish = html.index('id="main-content"')

    assert start && finish, "nav/main markers missing from page"
    html[start...finish]
  end

  def test_home_and_page_layout_aliases_render_the_docs_shell
    jekyll_build(config: config, files: files) do |site|
      assert_includes page(site, "/"), "flow-sidebar"
      assert_includes page(site, "/plain.html"), "flow-sidebar"
    end
  end

  def test_navbar_burgers_have_visible_names_and_four_decorative_lines
    jekyll_build(config: config, files: files) do |site|
      home = page(site, "/")
      top = page(site, "/top.html")

      assert_includes home, 'id="mobile-only-menu-label"'
      assert_includes home, 'class="flow-navbar-menu-label">Menu</span>'
      assert_includes top, '<span id="topnav-menu-label" class="flow-navbar-menu-label">Menu</span>'

      start = home.index('class="navbar-burger"')
      finish = home.index("</button>", start)
      assert start && finish, "mobile navbar burger missing"
      burger = home[start...finish]

      assert_includes burger, 'aria-labelledby="mobile-only-menu-label"'
      assert_equal 4, burger.scan('<span aria-hidden="true"></span>').size
      refute_includes burger, "is-sr-only"
    end
  end

  def test_search_dropdown_uses_combobox_and_listbox_semantics
    jekyll_build(config: config, files: files) do |site|
      home = page(site, "/")

      assert_includes home, 'role="combobox"'
      assert_includes home, 'aria-autocomplete="list"'
      assert_includes home, 'aria-haspopup="listbox"'
      assert_includes home, 'aria-controls="flow-search-results-full"'
      assert_includes home, '<div id="flow-search-results-full" class="flow-search-results"'
      assert_includes home, 'role="listbox" aria-label="Search suggestions"'
      assert_includes home, '<ul class="flow-search-results-items" role="presentation"'
      assert_includes home, 'aria-hidden="true" data-cs-dropdown-results></ul>'

      css = File.read(File.join(site.dest, "assets/css/theme.css"))
      assert_includes css, ".client-search-dropdown-item"
      assert_includes css, ".client-search-dropdown-link"
    end
  end

  def test_emits_seo_tag_metadata_without_site_side_config
    jekyll_build(config: config, files: files) do |site|
      home = page(site, "/")

      assert_includes home, "<title>Home | Parity Site</title>"
      assert_includes home, 'property="og:'
      assert_includes home, 'rel="canonical"'
      assert_includes home, "application/ld+json"
    end
  end

  def test_empty_include_hooks_pick_up_site_overrides
    jekyll_build(config: config, files: files) do |site|
      home = page(site, "/")

      assert_includes home, 'name="x-head-marker"'
      assert_includes home, "x-nav-footer"
      assert_includes home, "x-footer"
    end
  end

  def test_renders_breadcrumb_chain_from_parent_front_matter
    jekyll_build(config: config, files: files) do |site|
      grandchild = page(site, "/grandchild.html")

      assert_includes grandchild, 'class="breadcrumb'
      start = grandchild.index('class="breadcrumb')
      finish = grandchild.index("</nav>", start)
      assert finish, "breadcrumb nav not closed"
      crumbs = grandchild[start...finish]
      assert_includes crumbs, 'href="/section.html"'
      assert_includes crumbs, 'href="/child.html"'
      assert_includes crumbs, 'aria-current="page">Grandchild'

      refute_includes page(site, "/"), 'class="breadcrumb'
    end
  end

  def test_children_toc_lists_child_pages_and_has_toc_disables_it
    jekyll_build(config: config, files: files) do |site|
      section = page(site, "/section.html")

      assert_includes section, "flow-children-toc"
      # Heading text is covered by the toc_heading_custom override test.
      assert_includes section, 'href="/child.html"'

      # Child is itself a parent (of Grandchild) — its TOC lists it.
      child_toc = page(site, "/child.html")[/flow-children-toc.*/m]
      assert_includes child_toc, 'href="/grandchild.html"'

      refute_includes page(site, "/alpha.html"), "flow-children-toc"
      refute_includes page(site, "/no-toc.html"), "flow-children-toc"
    end
  end

  def test_nav_orders_nav_order_pages_before_title_sorted_pages
    jekyll_build(config: config, files: files) do |site|
      nav = nav_section(page(site, "/sorter.html"))

      assert_operator nav.index('href="/ordered.html"'), :<, nav.index('href="/alpha.html"')
      assert_operator nav.index('href="/alpha.html"'), :<, nav.index('href="/zebra.html"')
    end
  end

  def test_child_nav_order_reversed_flips_child_listing
    jekyll_build(config: config, files: files) do |site|
      toc = page(site, "/revparent.html")[/flow-children-toc.*/m]

      assert_operator toc.index('href="/rev-z.html"'), :<, toc.index('href="/rev-a.html"')
    end
  end

  def test_nav_enabled_false_renders_the_bare_shell
    jekyll_build(config: config, files: files) do |site|
      hidden = page(site, "/hidden.html")

      refute_includes hidden, "flow-sidebar"
      refute_includes hidden, "navbar"
    end
  end

  def test_nav_external_links_render_at_the_bottom_of_the_sidebar_nav
    jekyll_build(config: config, files: files) do |site|
      nav = nav_section(page(site, "/"))

      assert_includes nav, 'href="https://example.com/club"'
      assert_includes nav, 'target="_blank"'
      assert_includes nav, "external-link"
    end
  end

  def test_nav_external_local_links_respect_baseurl_and_absolute_urls_do_not
    settings = config.merge(
      "baseurl" => "/docs",
      "nav_external_links" => [
        { "title" => "Club", "url" => "https://example.com/club" },
        { "title" => "Guide", "url" => "/guide.html" }
      ]
    )
    jekyll_build(config: settings, files: files) do |site|
      nav = nav_section(page(site, "/"))

      assert_includes nav, 'href="https://example.com/club"'
      assert_includes nav, 'href="/docs/guide.html"'
    end
  end

  def test_aux_links_render_in_the_top_bar_with_new_tab
    jekyll_build(config: config, files: files) do |site|
      home = page(site, "/")

      assert_includes home, "flow-aux-links"
      assert_includes home, 'href="https://example.com/src"'
      assert_includes home, 'target="_blank"'
    end
  end

  def test_back_to_top_is_opt_in
    jekyll_build(config: config, files: files) do |site|
      refute_includes page(site, "/"), "back-to-top"
    end

    settings = config.merge("flow" => { "layout" => "sidebar-left", "back_to_top" => true })
    jekyll_build(config: settings, files: files) do |site|
      assert_includes page(site, "/"), "back-to-top"
      assert_includes page(site, "/"), 'aria-label="Back to top"'
    end
  end

  def test_last_modified_shows_in_footer_and_last_edit_disables_it
    jekyll_build(config: config, files: files) do |site|
      assert_includes page(site, "/dated.html"), "Page last modified:"
      refute_includes page(site, "/"), "Page last modified:"
    end

    settings = config.merge("flow" => { "layout" => "sidebar-left", "last_edit" => false })
    jekyll_build(config: settings, files: files) do |site|
      refute_includes page(site, "/dated.html"), "Page last modified:"
    end
  end

  def test_flow_theme_forces_a_bulma_color_scheme
    jekyll_build(config: config, files: files) do |site|
      refute_includes page(site, "/"), "data-theme"
    end

    settings = config.merge("flow" => { "layout" => "sidebar-left", "theme" => "dark" })
    jekyll_build(config: settings, files: files) do |site|
      assert_includes page(site, "/"), 'data-theme="dark"'
    end
  end

  def test_search_form_action_follows_dropdown_redirect_url
    jekyll_build(config: config, files: files) do |site|
      assert_includes page(site, "/"), 'action="/soeg/"'
    end
  end

  def test_renders_skip_link_main_content_id_and_table_wrap
    jekyll_build(config: config, files: files) do |site|
      home = page(site, "/")

      assert_includes home, 'class="skip-to-main" href="#main-content"'
      assert_includes home, 'id="main-content"'
      assert_includes home, "table-container"
    end

    settings = config.merge("flow" => { "layout" => "sidebar-left", "table_wrap" => false })
    jekyll_build(config: settings, files: files) do |site|
      refute_includes page(site, "/"), "table-container"
    end
  end

  def test_callout_aliases_ship_in_theme_css
    jekyll_build(config: config, files: files) do |site|
      css = File.read(File.join(site.dest, "assets/css/theme.css"))

      %w[.note .new .important .warning .highlight].each do |klass|
        assert_includes css, klass
      end
    end
  end

  def test_header_custom_renders_inside_the_top_bar
    jekyll_build(config: config, files: files) do |site|
      home = page(site, "/")

      assert_includes home, "x-header-marker"
      assert_operator home.index("flow-topbar"), :<, home.index("x-header-marker")
      assert_operator home.index("x-header-marker"), :<, home.index('id="main-content"')
    end
  end

  def test_toc_heading_custom_overrides_the_heading
    jekyll_build(config: config, files: files) do |site|
      section = page(site, "/section.html")

      assert_includes section, "Custom contents"
      refute_includes section, "Table of contents"
    end
  end

  def test_default_toc_heading_without_site_override
    plain_files = jekyll_files do
      file "index.md" do
        frontmatter("layout" => "default", "title" => "Home")
        contents "Welcome"
      end
      file "section.md" do
        frontmatter("layout" => "default", "title" => "Section")
        contents "Section page"
      end
      file "child.md" do
        frontmatter("layout" => "default", "title" => "Child", "parent" => "Section")
        contents "Child page"
      end
    end
    jekyll_build(config: config, files: plain_files) do |site|
      assert_includes page(site, "/section.html"), "Table of contents"
    end
  end

  def test_post_layout_alias_renders_the_docs_shell
    jekyll_build(config: config, files: files) do |site|
      assert_includes page(site, "/blog.html"), "flow-sidebar"
    end
  end

  def test_child_nav_order_descending_flips_child_listing
    jekyll_build(config: config, files: files) do |site|
      toc = page(site, "/descparent.html")[/flow-children-toc.*/m]

      assert toc, "children toc missing"
      assert_operator toc.index('href="/desc-z.html"'), :<, toc.index('href="/desc-a.html"')
    end
  end

  def test_site_wide_switches_disable_breadcrumbs_and_children_toc
    settings = config.merge("flow" => { "layout" => "sidebar-left",
                                        "breadcrumbs" => false, "children_toc" => false })
    jekyll_build(config: settings, files: files) do |site|
      refute_includes page(site, "/grandchild.html"), 'class="breadcrumb'
      refute_includes page(site, "/section.html"), "flow-children-toc"
    end
  end

  def test_aux_links_render_in_topnav_navbar_end
    jekyll_build(config: config, files: files) do |site|
      # navbar-end only exists in the topnav shell — sidebar pages put
      # aux links in the top bar instead.
      top = page(site, "/top.html")

      assert_includes top, "navbar-end"
      navbar_end = top[top.index("navbar-end")..]
      assert_includes navbar_end, 'href="https://example.com/src"'
    end
  end

  def test_last_modified_date_jtd_format_and_timestamp_keys
    jekyll_build(config: config, files: files) do |site|
      # last_edit_time_format "%Y" applies to both source keys
      assert_includes page(site, "/dated.html"), "Page last modified: 2026"
      assert_includes page(site, "/dated2.html"), "Page last modified: 2026"
    end

    settings = config.merge("last_edit_timestamp" => false)
    jekyll_build(config: settings, files: files) do |site|
      refute_includes page(site, "/dated.html"), "Page last modified:"
    end
  end

  def test_favicon_ico_fallback_and_flow_favicon_precedence
    jekyll_build(config: config, files: files) do |site|
      assert_includes page(site, "/"), 'rel="icon" href="/icons/parity.ico"'
    end

    settings = config.merge("flow" => { "layout" => "sidebar-left",
                                        "favicon" => "/flow/wins.ico" })
    jekyll_build(config: settings, files: files) do |site|
      assert_includes page(site, "/"), 'rel="icon" href="/flow/wins.ico"'
    end
  end

  def test_footer_content_config_renders_in_footer
    jekyll_build(config: config, files: files) do |site|
      assert_includes page(site, "/"), "Built with tests"
    end
  end

  def test_footer_content_is_escaped_and_markup_uses_footer_custom_hook
    settings = config.merge("footer_content" => '<script>alert("unsafe")</script>')
    jekyll_build(config: settings, files: files) do |site|
      html = page(site, "/")

      assert_includes html, "&lt;script&gt;alert(&quot;unsafe&quot;)&lt;/script&gt;"
      refute_includes html, '<script>alert("unsafe")</script>'
      assert_includes html, '<span class="x-footer">extra footer</span>'
    end
  end

  def test_search_placeholder_custom_overrides_the_placeholder
    jekyll_build(config: config, files: files) do |site|
      assert_includes page(site, "/"), 'placeholder="Søg i arkivet"'
    end
  end

  def test_precomputes_flow_nav_tree_and_index_when_plugin_loaded
    jekyll_build(config: config, files: files) do |site|
      nav = site.data["flow_nav"]

      assert nav, "flow_nav missing — generator did not run"
      assert_equal "Home", nav["roots"].first["title"]

      section = nav["index"]["Section"]
      assert_equal "/section.html", section["url"]
      assert_equal "/child.html", section["children"].first["url"]
      assert_equal "/grandchild.html", section["children"].first["children"].first["url"]

      sort_children = nav["index"]["SortSection"]["children"].map { |n| n["url"] }
      assert_equal ["/ordered.html", "/alpha.html", "/zebra.html"], sort_children

      rev_children = nav["index"]["Reversed"]["children"].map { |n| n["url"] }
      assert_equal ["/rev-z.html", "/rev-a.html"], rev_children

      desc_children = nav["index"]["DescParent"]["children"].map { |n| n["url"] }
      assert_equal ["/desc-z.html", "/desc-a.html"], desc_children
    end
  end

  # flow.nav_cache: false exercises the same Liquid fallback a
  # `theme:`-only consumer gets (the plugin never loads, flow_nav is
  # never populated).
  def test_nav_and_breadcrumbs_fall_back_with_nav_cache_disabled
    settings = config.merge("flow" => { "layout" => "sidebar-left", "nav_cache" => false })
    jekyll_build(config: settings, files: files) do |site|
      assert_nil site.data["flow_nav"]

      nav = nav_section(page(site, "/sorter.html"))
      assert_operator nav.index('href="/ordered.html"'), :<, nav.index('href="/alpha.html"')
      assert_operator nav.index('href="/alpha.html"'), :<, nav.index('href="/zebra.html"')

      grandchild = page(site, "/grandchild.html")
      assert_includes grandchild, 'class="breadcrumb'
      assert_includes page(site, "/section.html"), "flow-children-toc"
    end
  end

  def test_escapes_unsafe_aux_external_and_breadcrumb_titles
    settings = config.merge(
      "aux_links" => { '<img src=x onerror="alert(1)">' => "https://example.com/x" },
      "nav_external_links" => [
        { "title" => '<b onmouseover="alert(1)">', "url" => "https://example.com/club" }
      ]
    )
    jekyll_build(config: settings, files: files) do |site|
      home = page(site, "/")

      assert_includes home, "&lt;img src=x onerror=&quot;alert(1)&quot;&gt;"
      assert_includes home, "&lt;b onmouseover=&quot;alert(1)&quot;&gt;"
      refute_includes home, 'onerror="alert(1)"><'
      refute_includes home, '<b onmouseover="alert(1)">'

      child = page(site, "/unsafe-child.html")
      start = child.index('class="breadcrumb')
      finish = child.index("</nav>", start)
      assert start && finish
      crumbs = child[start...finish]
      assert_includes crumbs, "&lt;img src=x onerror=&quot;alert(1)&quot;&gt;"
      refute_includes crumbs, '<img src=x onerror="alert(1)">'
    end
  end
end
