require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'paperclip'
require 'warden'
require 'sinatra/flash'
require_relative './controllers/ssh_connection'
require_relative './controllers/player'
require_relative './helpers/SiteHelper'

require './config/environment'

Dir["#{__dir__}/models/*.rb"].each { |file| require_relative file }

require_relative 'routes/user_routes'
set :bind, '0.0.0.0'
