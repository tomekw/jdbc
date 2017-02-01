require "simplecov"

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "jdbc"

if ENV["CIRCLE_ARTIFACTS"]
  SimpleCov.coverage_dir(File.join(ENV["CIRCLE_ARTIFACTS"], "coverage"))
end

SimpleCov.start

RSpec.configure do |config|
  config.order = :random
end
