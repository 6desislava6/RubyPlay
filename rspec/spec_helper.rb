# http://recipes.sinatrarb.com/p/testing/rspec
require 'rack/test'
require 'rspec'

ENV['RACK_ENV'] = 'test'

require_relative "../config/environment"
require_relative '../../app.rb'

module RSpecMixin
  include Rack::Test::Methods
  def app() RubyPlay end

end

# For RSpec 2.x and 3.x
RSpec.configure { |c| c.include RSpecMixin }
