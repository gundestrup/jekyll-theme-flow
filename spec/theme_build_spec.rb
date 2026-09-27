# frozen_string_literal: true

require "spec_helper"

# Full-build coverage: a real site consuming the theme end to end —
# layout dispatch, nav tree, search chrome, and icon tags are all
# asserted against generated output, not eyeballing the demo.
RSpec.describe "jekyll-theme-flow site build" do
  let(:files) do
    jekyll_files do
      file "index.md" do
        frontmatter("layout" => "default", "title" => "Home", "nav_order" => 1)
        contents "Welcome"
      end
      file "section.md" do
        frontmatter("layout" => "default", "title" => "Section", "nav_order" => 2)
        contents "Section page"
      end
      file "child.md" do
        frontmatter("layout" => "default", "title" => "Child", "parent" => "Section")
        contents "Child page {% icon home %}"
      end
      file "nav-page.md" do
        frontmatter("layout" => "topnav", "title" => "Topnav")
        contents "Navbar page"
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
      "theme" => "jekyll-theme-flow",
      "plugins" => %w[jekyll-client-search jekyll-icon-flow],
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

  it "compiles theme Sass and emits search assets" do
    jekyll_build(config: config, files: files) do |site|
      expect(File.exist?(File.join(site.dest, "assets/css/theme.css"))).to be true
      expect(File.exist?(File.join(site.dest, "search-index.json"))).to be true
      expect(File.exist?(File.join(site.dest, "search", "index.html"))).to be true
    end
  end
end
