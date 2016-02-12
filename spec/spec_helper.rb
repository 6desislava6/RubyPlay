ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'capybara/rspec'
require 'rack/test'

require_relative '../app'

Dir["#{__dir__}/support/*.rb"].each { |file| require_relative file }
Capybara.app = RubyPlay

module RSpecMixin
  include Rack::Test::Methods
  def app()
    RubyPlay
  end
end

RSpec.configure do |config|
  config.include RSpecMixin
  config.include Warden::Test::Helpers
  config.before :suite do
    Warden.test_mode!
  end
  config.after :each do
    Warden.test_reset!
  end
end
