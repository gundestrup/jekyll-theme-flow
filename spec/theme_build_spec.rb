# frozen_string_literal: true

require "spec_helper"

# Full-build coverage: a real site consuming the theme end to end —
# layout dispatch, nav tree, search chrome, and icon tags are all
# asserted against generated output, not eyeballing the demo.
RSpec.describe "jekyll-theme-flow site build" do
  let(:files) do
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

  let(:config) do
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

  it "renders the sidebar shell, nav tree, search bar, and icons" do
    jekyll_build(config: config, files: files) do |site|
      home = site.pages.find { |p| p.url == "/" }.output

      expect(home).to include("flow-shell")
      expect(home).to include("flow-sidebar")
      expect(home).to include('class="menu-list"')
      expect(home).to include("flow-search")
      expect(home).to include("data-icon-pack=")
    end
  end

  it "nests child pages under their parent in the nav tree" do
    jekyll_build(config: config, files: files) do |site|
      child = site.pages.find { |p| p.url == "/child.html" }.output

      expect(child).to include("Section")
      expect(child).to include('href="/child.html"')
      expect(child.scan('class="menu-list"').size).to be > 1
    end
  end

  it "renders the topnav layout as navbar, no sidebar" do
    jekyll_build(config: config, files: files) do |site|
      nav_page = site.pages.find { |p| p.url == "/nav-page.html" }.output

      expect(nav_page).to include("navbar")
      expect(nav_page).not_to include("flow-sidebar")
    end
  end

  it "escapes site and page metadata in HTML contexts" do
    unsafe = 'A" onmouseover="alert(1) & <unsafe>'
    settings = config.merge("title" => unsafe, "flow" => {
                              "layout" => "sidebar-left", "logo" => '/logo" onerror="alert(1).svg',
                              "favicon" => '/icon" onload="alert(1).ico',
                              "search_placeholder" => unsafe, "footer_text" => unsafe
                            })
    jekyll_build(config: settings, files: files) do |site|
      home = site.pages.find { |p| p.url == "/" }.output
      expect(home).to include("A&quot; onmouseover=&quot;alert(1) &amp; &lt;unsafe&gt;")
      expect(home).to include('src="/logo%22%20onerror=%22alert(1).svg"')
      expect(home).to include('href="/icon%22%20onload=%22alert(1).ico"')
      expect(home).not_to include(' onerror="alert(1)')
      expect(home).to include("&lt;unsafe&quot; onfocus=&quot;alert(1)&gt;")
      expect(home).not_to include('<unsafe" onfocus="alert(1)>')
    end
  end

  # Pages using `icon:` must name icons in the configured pack — the
  # strict-mode build below uses a fixture without nav icons.
  let(:files_no_nav_icons) do
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

  it "keeps theme chrome visible when the site uses a brand icon pack" do
    settings = config.merge("icon_flow" => { "pack" => "simple", "on_missing" => "strict" })
    jekyll_build(config: settings, files: files_no_nav_icons) do |site|
      home = site.pages.find { |p| p.url == "/" }.output
      expect(home).to include('class="lucide lucide-search icon icon-search"')
      expect(home).to include("icon-chevron-right")
    end
  end

  it "supports search submission without dropdown JavaScript" do
    settings = config.merge("client_search" => config.fetch("client_search").merge(
      "dropdown" => { "enabled" => false }
    ))
    jekyll_build(config: settings, files: files) do |site|
      home = site.pages.find { |p| p.url == "/" }.output
      expect(home).to include('action="/search/"')
      expect(home).to include('method="get"')
      expect(home).not_to include("client-search-dropdown.js")
    end
  end

  it "renders the right and bare layouts with their intended chrome" do
    jekyll_build(config: config, files: files) do |site|
      right = site.pages.find { |p| p.url == "/right-page.html" }.output
      bare = site.pages.find { |p| p.url == "/bare-page.html" }.output
      expect(right).to include("flow-sidebar flow-right")
      expect(bare).not_to include("flow-sidebar", "flow-search", "navbar")
    end
  end

  it "respects the icon, logo, favicon and search toggles" do
    flow = { "logo" => "/logo.svg", "logo_enabled" => false,
             "favicon" => "/favicon.ico", "favicon_enabled" => false }
    settings = config.merge("flow" => flow, "icon_flow" => { "enabled" => false },
                            "client_search" => { "enabled" => false })
    jekyll_build(config: settings, files: files) do |site|
      home = site.pages.find { |p| p.url == "/" }.output
      expect(home).not_to include("flow-brand-icon", "rel=\"icon\"")
      expect(home).not_to include("flow-search", "data-icon-pack=")
    end
  end

  it "renders the archive banner, version links, and noindex on archived pages" do
    jekyll_build(config: config, files: files) do |site|
      old = site.pages.find { |p| p.url == "/archive/old-section.html" }.output

      expect(old).to include("notification is-warning")
      expect(old).to include('href="/section.html"')
      expect(old).to include('content="noindex"')
      expect(old).to include('href="/archive/older-section.html"')
      expect(old).to include("(current)")
      expect(old).to include("(archived)")

      home = site.pages.find { |p| p.url == "/" }.output
      expect(home).not_to include("noindex")
    end
  end

  it "lists archived versions on the current page and the archive index" do
    jekyll_build(config: config, files: files) do |site|
      section = site.pages.find { |p| p.url == "/section.html" }.output
      expect(section).to include("Previous versions")
      expect(section).to include('href="/archive/old-section.html"')
      expect(section).to include('href="/archive/older-section.html"')

      index = site.pages.find { |p| p.url == "/archive/" }.output
      expect(index).to include('href="/archive/old-section.html"')
      expect(index).to include('href="/archive/older-section.html"')
      expect(index).to include("replaced by")
    end
  end

  it "marks the current nav item and its parent active, and renders nav icons" do
    jekyll_build(config: config, files: files) do |site|
      child = site.pages.find { |p| p.url == "/child.html" }.output
      expect(child).to include('href="/section.html" class="is-active"')

      home = site.pages.find { |p| p.url == "/" }.output
      expect(home).to include("icon icon-home")

      topnav_child = site.pages.find { |p| p.url == "/topnav-child.html" }.output
      expect(topnav_child).to include('class="navbar-link is-active" href="/nav-page.html"')
    end
  end

  it "generates a sitemap that excludes archived pages" do
    jekyll_build(config: config, files: files) do |site|
      sitemap = File.read(File.join(site.dest, "sitemap.xml"))

      expect(sitemap).to include("/section.html")
      expect(sitemap).not_to include("/archive/old-section.html")
      expect(sitemap).not_to include("/archive/older-section.html")
    end
  end

  it "honours the sitemap config switches" do
    no_sitemap = config.merge("flow" => { "layout" => "sidebar-left", "sitemap" => false })
    jekyll_build(config: no_sitemap, files: files) do |site|
      expect(File.exist?(File.join(site.dest, "sitemap.xml"))).to be false
    end

    keep = config.merge("flow" => { "layout" => "sidebar-left",
                                    "archive" => { "sitemap_exclude" => false } })
    jekyll_build(config: keep, files: files) do |site|
      sitemap = File.read(File.join(site.dest, "sitemap.xml"))
      expect(sitemap).to include("/archive/old-section.html")
    end
  end

  it "compiles theme Sass and emits search assets" do
    jekyll_build(config: config, files: files) do |site|
      expect(File.exist?(File.join(site.dest, "assets/css/theme.css"))).to be true
      expect(File.exist?(File.join(site.dest, "search-index.json"))).to be true
      expect(File.exist?(File.join(site.dest, "search", "index.html"))).to be true
    end
  end
end
