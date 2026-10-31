# frozen_string_literal: true

require "test_helper"

# Full-build coverage: a real site consuming the theme end to end —
# layout dispatch, nav tree, search chrome, and icon tags are all
# asserted against generated output, not eyeballing the demo.
class ThemeBuildTest < Minitest::Test
  def files
    jekyll_files do
      file "index.md" do
        frontmatter("layout" => "default", "title" => "Home", "nav_order" => 1, "icon" => "home")
        contents "Welcome"
      end
      file "section.md" do
        frontmatter("layout" => "default", "title" => "Section", "nav_order" => 2)
        contents "Section page\n\n{% include archive_versions.html %}"
      end
      file "child.md" do
        frontmatter("layout" => "default", "title" => "Child", "parent" => "Section")
        contents "Child page {% icon_lucide home %}"
      end
      file "nav-page.md" do
        frontmatter("layout" => "topnav", "title" => "Topnav")
        contents "Navbar page"
      end
      file "topnav-child.md" do
        frontmatter("layout" => "topnav", "title" => "Topnav Child", "parent" => "Topnav")
        contents "Dropdown child"
      end
      file "archive/old-section.md" do
        frontmatter("layout" => "archive", "title" => "Old Section",
                    "permalink" => "/archive/old-section.html",
                    "archive_link_current" => "/section.html", "nav_exclude" => true)
        contents "Outdated"
      end
      file "archive/older-section.md" do
        frontmatter("layout" => "archive", "title" => "Ancient Section",
                    "permalink" => "/archive/older-section.html",
                    "archive_link_current" => "/section.html", "nav_exclude" => true)
        contents "Even older"
      end
      file "arkiv.md" do
        frontmatter("layout" => "archive-index", "title" => "Archive",
                    "permalink" => "/archive/", "nav_exclude" => true)
        contents "Older versions of pages."
      end
      file "right-page.md" do
        frontmatter("layout" => "sidebar-right", "title" => "Right")
        contents "Right sidebar page"
      end
      file "bare-page.md" do
        frontmatter("layout" => "bare", "title" => "Bare")
        contents "Bare page"
      end
      file "unsafe.md" do
        frontmatter("layout" => "default", "title" => '<unsafe" onfocus="alert(1)>')
        contents "Safe page"
      end
      # Themes only ship _layouts/_includes/_sass/assets — consumers add
      # their own search.md using the theme's `search` layout
      file "search.md" do
        frontmatter("layout" => "search", "title" => "Search", "permalink" => "/search/")
        contents ""
      end
    end
  end

  def config
    {
      "title" => "Spec Site",
      "url" => "http://example.test",
      "theme" => "jekyll-theme-flow",
      "plugins" => %w[jekyll-client-search jekyll-icon-flow jekyll-theme-flow],
      "flow" => { "layout" => "sidebar-left" },
      "client_search" => {
        "enabled" => true,
        "engine" => "minisearch",
        "include_pages" => true,
        "dropdown" => { "enabled" => true, "redirect_url" => "/search/" }
      },
      "icon_flow" => { "pack" => "lucide" }
    }
  end

  def test_renders_sidebar_shell_nav_tree_search_bar_and_icons
    jekyll_build(config: config, files: files) do |site|
      home = site.pages.find { |p| p.url == "/" }.output

      assert_includes home, "flow-shell"
      assert_includes home, "flow-sidebar"
      assert_includes home, 'class="menu-list"'
      assert_includes home, "flow-search"
      assert_includes home, "data-icon-pack="
    end
  end

  def test_nests_child_pages_under_parent_in_nav_tree
    jekyll_build(config: config, files: files) do |site|
      child = site.pages.find { |p| p.url == "/child.html" }.output

      assert_includes child, "Section"
      assert_includes child, 'href="/child.html"'
      assert_operator child.scan('class="menu-list"').size, :>, 1
    end
  end

  def test_renders_topnav_layout_as_navbar_without_sidebar
    jekyll_build(config: config, files: files) do |site|
      nav_page = site.pages.find { |p| p.url == "/nav-page.html" }.output

      assert_includes nav_page, "navbar"
      refute_includes nav_page, "flow-sidebar"
    end
  end

  def test_escapes_site_and_page_metadata_in_html_contexts
    unsafe = 'A" onmouseover="alert(1) & <unsafe>'
    settings = config.merge("title" => unsafe, "flow" => {
                              "layout" => "sidebar-left", "logo" => '/logo" onerror="alert(1).svg',
                              "favicon" => '/icon" onload="alert(1).ico',
                              "search_placeholder" => unsafe, "footer_text" => unsafe
                            })
    jekyll_build(config: settings, files: files) do |site|
      home = site.pages.find { |p| p.url == "/" }.output
      assert_includes home, "A&quot; onmouseover=&quot;alert(1) &amp; &lt;unsafe&gt;"
      assert_includes home, 'src="/logo%22%20onerror=%22alert(1).svg"'
      assert_includes home, 'href="/icon%22%20onload=%22alert(1).ico"'
      refute_includes home, ' onerror="alert(1)'
      assert_includes home, "&lt;unsafe&quot; onfocus=&quot;alert(1)&gt;"
      refute_includes home, '<unsafe" onfocus="alert(1)>'
    end
  end

  # Pages using `icon:` must name icons in the configured pack — the
  # strict-mode build below uses a fixture without nav icons.
  def files_no_nav_icons
    jekyll_files do
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
  end

  def test_keeps_theme_chrome_visible_with_brand_icon_pack
    settings = config.merge("icon_flow" => { "pack" => "simple", "on_missing" => "strict" })
    jekyll_build(config: settings, files: files_no_nav_icons) do |site|
      home = site.pages.find { |p| p.url == "/" }.output
      assert_includes home, 'class="lucide lucide-search icon icon-search"'
      assert_includes home, "icon-chevron-right"
    end
  end

  def test_supports_search_submission_without_dropdown_javascript
    settings = config.merge("client_search" => config.fetch("client_search").merge(
      "dropdown" => { "enabled" => false }
    ))
    jekyll_build(config: settings, files: files) do |site|
      home = site.pages.find { |p| p.url == "/" }.output
      assert_includes home, 'action="/search/"'
      assert_includes home, 'method="get"'
      refute_includes home, "client-search-dropdown.js"
    end
  end

  def test_renders_right_and_bare_layouts_with_intended_chrome
    jekyll_build(config: config, files: files) do |site|
      right = site.pages.find { |p| p.url == "/right-page.html" }.output
      bare = site.pages.find { |p| p.url == "/bare-page.html" }.output
      assert_includes right, "flow-sidebar flow-right"
      refute_includes bare, "flow-sidebar"
      refute_includes bare, "flow-search"
      refute_includes bare, "navbar"
    end
  end

  def test_respects_icon_logo_favicon_and_search_toggles
    flow = { "logo" => "/logo.svg", "logo_enabled" => false,
             "favicon" => "/favicon.ico", "favicon_enabled" => false }
    settings = config.merge("flow" => flow, "icon_flow" => { "enabled" => false },
                            "client_search" => { "enabled" => false })
    jekyll_build(config: settings, files: files) do |site|
      home = site.pages.find { |p| p.url == "/" }.output
      refute_includes home, "flow-brand-icon"
      refute_includes home, 'rel="icon"'
      refute_includes home, "flow-search"
      refute_includes home, "data-icon-pack="
    end
  end

  def test_renders_archive_banner_version_links_and_noindex
    jekyll_build(config: config, files: files) do |site|
      old = site.pages.find { |p| p.url == "/archive/old-section.html" }.output

      assert_includes old, "notification is-warning"
      assert_includes old, 'href="/section.html"'
      assert_includes old, 'content="noindex"'
      assert_includes old, 'href="/archive/older-section.html"'
      assert_includes old, "(current)"
      assert_includes old, "(archived)"

      home = site.pages.find { |p| p.url == "/" }.output
      refute_includes home, "noindex"
    end
  end

  def test_lists_archived_versions_on_current_page_and_archive_index
    jekyll_build(config: config, files: files) do |site|
      section = site.pages.find { |p| p.url == "/section.html" }.output
      assert_includes section, "Previous versions"
      assert_includes section, 'href="/archive/old-section.html"'
      assert_includes section, 'href="/archive/older-section.html"'

      index = site.pages.find { |p| p.url == "/archive/" }.output
      assert_includes index, 'href="/archive/old-section.html"'
      assert_includes index, 'href="/archive/older-section.html"'
      assert_includes index, "replaced by"
    end
  end

  def test_marks_current_nav_item_and_parent_active_and_renders_nav_icons
    jekyll_build(config: config, files: files) do |site|
      child = site.pages.find { |p| p.url == "/child.html" }.output
      assert_includes child, 'href="/section.html" class="is-active"'

      home = site.pages.find { |p| p.url == "/" }.output
      assert_includes home, "icon icon-home"

      topnav_child = site.pages.find { |p| p.url == "/topnav-child.html" }.output
      assert_includes topnav_child, 'class="navbar-link is-active" href="/nav-page.html"'
    end
  end

  def test_generates_sitemap_excluding_archived_pages
    jekyll_build(config: config, files: files) do |site|
      sitemap = File.read(File.join(site.dest, "sitemap.xml"))

      assert_includes sitemap, "/section.html"
      refute_includes sitemap, "/archive/old-section.html"
      refute_includes sitemap, "/archive/older-section.html"
    end
  end

  def test_injects_config_defaults_consumer_can_override
    jekyll_build(config: config, files: files) do |site|
      assert_equal true, site.config.dig("sass", "quiet_deps")
    end

    overridden = config.merge("sass" => { "quiet_deps" => false })
    jekyll_build(config: overridden, files: files) do |site|
      assert_equal false, site.config.dig("sass", "quiet_deps")
    end
  end

  def test_honours_sitemap_config_switches
    no_sitemap = config.merge("flow" => { "layout" => "sidebar-left", "sitemap" => false })
    jekyll_build(config: no_sitemap, files: files) do |site|
      refute File.exist?(File.join(site.dest, "sitemap.xml"))
    end

    keep = config.merge("flow" => { "layout" => "sidebar-left",
                                    "archive" => { "sitemap_exclude" => false } })
    jekyll_build(config: keep, files: files) do |site|
      sitemap = File.read(File.join(site.dest, "sitemap.xml"))
      assert_includes sitemap, "/archive/old-section.html"
    end
  end

  # The sitemap-exclusion hook registers every renderable container —
  # `layout: archive` must keep posts and collection documents out of
  # sitemap.xml exactly like pages do.
  def test_excludes_archived_posts_and_documents_from_sitemap
    non_page_files = jekyll_files do
      file "index.md" do
        frontmatter("layout" => "default", "title" => "Home")
        contents "Welcome"
      end
      file "_posts/2026-01-01-old-post.md" do
        frontmatter("layout" => "archive", "title" => "Old Post")
        contents "Outdated post"
      end
      file "_docs/old-doc.md" do
        frontmatter("layout" => "archive", "title" => "Old Doc")
        contents "Outdated doc"
      end
    end
    settings = config.merge("collections" => { "docs" => { "output" => true } })
    jekyll_build(config: settings, files: non_page_files) do |site|
      assert File.exist?(File.join(site.dest, "2026", "01", "01", "old-post.html"))
      assert File.exist?(File.join(site.dest, "docs", "old-doc.html"))

      sitemap = File.read(File.join(site.dest, "sitemap.xml"))
      assert_includes sitemap, "/"
      refute_includes sitemap, "old-post"
      refute_includes sitemap, "old-doc"
    end
  end

  def test_compiles_theme_sass_and_emits_search_assets
    jekyll_build(config: config, files: files) do |site|
      assert File.exist?(File.join(site.dest, "assets/css/theme.css"))
      assert File.exist?(File.join(site.dest, "search-index.json"))
      assert File.exist?(File.join(site.dest, "search", "index.html"))
    end
  end
end
