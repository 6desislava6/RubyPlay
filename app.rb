require 'sinatra/base'
require 'sinatra/activerecord'

require './config/environments'

require_relative 'models/User'
require_relative 'models/AudioFile'
require_relative 'models/Playlist'

require_relative 'routes/user_routes'
