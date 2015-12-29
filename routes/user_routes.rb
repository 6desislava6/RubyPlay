require 'sinatra/base'
require 'sinatra/activerecord'
require './models/User'
require './models/AudioFile'
require './models/Playlist'

class RubyPlay < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :database, {adapter: 'sqlite3', database: 'ruby_play.sqlite3'}
  set :views, Proc.new { File.join(root, "../views") }

  get '/' do
    erb :home
  end

  get '/users/:id' do
    @users = User.find_by_id(params[:id])
    @users.name
    end

  post "/new" do
    p params[:user]
    @user = User.new
    @user.name = params[:user_name]
    a = @user.save!
    if a
      redirect "users/#{@user.id}"
    else
      erb :new
    end
  end

end

