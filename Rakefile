# frozen_string_literal: true

require "rspec/core/rake_task"
require "rubocop/rake_task"
require "bundler/audit/task"
require "bundler/gem_tasks"
require "rubygems/package"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new
Bundler::Audit::Task.new

GEMSPEC = "jekyll-theme-flow.gemspec"

namespace :version do
  task :show do
    puts Gem::Specification.load(GEMSPEC).version
  end

  task :check do
    version = Gem::Specification.load(GEMSPEC).version.to_s
    changelog = File.read("CHANGELOG.md")
    abort "Missing changelog entry for #{version}" unless changelog.include?("## [#{version}]")
  end

  task :check_changelog do
    version = Gem::Specification.load(GEMSPEC).version.to_s
    abort "Add a dated changelog entry for #{version}" unless
      File.read("CHANGELOG.md").match?(/^## \[#{Regexp.escape(version)}\] - \d{4}-\d{2}-\d{2}$/)
  end
end

task "version:bump", [:part] do |_task, args|
  part = args[:part].to_s
  abort "Use patch, minor or major" unless %w[patch minor major].include?(part)

  current = Gem::Specification.load(GEMSPEC).version.segments
  index = { "major" => 0, "minor" => 1, "patch" => 2 }.fetch(part)
  current.fill(0, current.length...3)
  current[index] += 1
  current.fill(0, (index + 1)...current.length)
  next_version = current.join(".")
  content = File.read(GEMSPEC)
  content = content.sub(/spec\.version\s*=\s*"[^"]+"/, "spec.version       = \"#{next_version}\"")
  File.write(GEMSPEC, content)
  sh "bundle", "lock" unless ENV["SKIP_LOCK"]
  puts "Bumped to #{next_version}; add a CHANGELOG.md entry"
end

task :package do
  spec = Gem::Specification.load(GEMSPEC)
  file = Gem::Package.build(spec)
  contents = Gem::Package.new(file).contents
  required = %w[LICENSE.txt README.md CHANGELOG.md lib/jekyll-theme-flow.rb
                _layouts/default.html _layouts/search.html
                _layouts/archive.html _layouts/archive-index.html _includes/archive_versions.html
                _includes/search_slot.html _sass/flow.scss assets/css/theme.scss
                assets/js/alpine.min.js]
  abort "Gem missing: #{(required - contents).join(', ')}" unless (required - contents).empty?
  demo_pages = contents.grep(/\.md\z/) - %w[README.md CHANGELOG.md]
  abort "Demo pages must not ship in a theme gem: #{demo_pages.join(', ')}" unless demo_pages.empty?
end

task :semgrep do
  # Scan the repo root: semgrep limits itself to git-tracked files anyway,
  # and explicit dirs turn into hard "invalid scanning root" errors if a
  # directory is ever renamed or removed.
  sh "semgrep", "scan", "--config", ".semgrep.yml", "--error", "--metrics", "off", "."
end

task quick: %i[rubocop spec]
task ci: %i[rubocop bundle:audit semgrep spec version:check package]
task "version:pre_release" => %i[ci version:check_changelog]

desc "Build the demo site"
task :demo_build do
  sh "bundle exec jekyll build"
end

desc "Serve the demo site"
task :serve do
  sh "bundle exec jekyll serve"
end

task default: :quick
