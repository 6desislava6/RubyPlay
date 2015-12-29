require 'sinatra/base'
require 'sinatra/activerecord'
require './models/User'
require './models/AudioFile'
require './models/Playlist'
require 'paperclip'
# require 'net/scp'
# require 'net/ssh'

require_relative '../controllers/ssh_connection'

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

  get '/file' do
    erb :file_upload
  end

  get '/files' do
    @audio_files = AudioFile.all
    erb :all_audio_files
  end

  get '/play_song' do
    erb :play_song
  end


  post '/files' do
    audio_file = AudioFile.find(params[:id].to_i)
    path = make_math(params, audio_file)

    HOST = "10.42.0.136"
    USER = "pi"
    ssh = SSHConnector.new(HOST, USER, [])
    ssh.upload_song(path, audio_file.title)
    ssh.play_song(audio_file.title)
    "Playing"
  end

  def make_math(params, audio_file)
    "./public/system/files/#{params[:id]}/original/" + audio_file.file_file_name + '.'
  end

  post '/file' do
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
