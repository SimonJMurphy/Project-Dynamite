%w{rubygems
  bundler/setup
  kepler_processor}.each { |file| require file }

RSpec.configure do |config|
  config.mock_with :rspec
  # some (optional) config here
end
