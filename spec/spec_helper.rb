require 'rubygems'
require 'bundler/setup'

require 'kepler_processor'

RSpec.configure do |config|
  config.mock_with :rspec
  # some (optional) config here
  config.before(:each) { LOGGER ||= mock('logger').as_null_object }
end
