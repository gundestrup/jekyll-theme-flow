# frozen_string_literal: true

require "jekyll"
require "jekyll_test_harness"
require "rspec"

JekyllTestHarness.install!(framework: :rspec)

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end
