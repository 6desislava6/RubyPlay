require 'rack/spec'

set :environment, :test

def app
  Sinatra::Application
end

describe 'Ruby Play' do
  include Rack::Test::Methods
  it 'should load the main page' do
    get '/'
    last_response.should be_ok
  end
end
