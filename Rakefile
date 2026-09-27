# frozen_string_literal: true

require "rspec/core/rake_task"
require "rubocop/rake_task"
require "bundler/audit/task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new
Bundler::Audit::Task.new

task quick: %i[rubocop spec]
task ci: %i[rubocop bundle:audit spec]

desc "Build the demo site"
task :build do
  sh "bundle exec jekyll build"
end

desc "Serve the demo site"
task :serve do
  sh "bundle exec jekyll serve"
end

task default: :quick
