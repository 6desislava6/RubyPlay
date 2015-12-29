require 'sinatra/base'
require 'sinatra/activerecord'
require './models/User'
require './models/AudioFile'
require './models/Playlist'
require "paperclip"


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

  get '/file' do
    erb :file_upload
  end

  post "/file" do
    #@filename = params[:file][:filename]
    #params[:photo][:image] = params[:photo][:image][:tempfile] if params[:photo][:image]

    title = params[:file][:filename]
    file = params[:file][:tempfile]
    @audio_file = AudioFile.new
    @audio_file.title = title
    @audio_file.file = file
    success = @audio_file.save
    if success
        { :status => "OK"}.to_json
    else
        { :status => "NOK"}.to_json
    end
  end

end
