# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

unless ENV["COVERAGE"] == "false"
  require "simplecov"
  if ENV["CI"]
    require "simplecov-cobertura"
    SimpleCov.formatter SimpleCov::Formatter::CoberturaFormatter
  end
  SimpleCov.start do
    cover "lib/**/*.rb"
    minimum_coverage 90 if ENV["CI"]
  end
end

require "jekyll"
require "jekyll_test_harness"
require "rspec"

JekyllTestHarness.install!(framework: :rspec)

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end
