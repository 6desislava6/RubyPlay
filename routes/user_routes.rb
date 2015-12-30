require 'sinatra/base'
require 'sinatra/activerecord'
require './models/User'
require './models/AudioFile'
require './models/Playlist'
require 'paperclip'

require_relative '../controllers/ssh_connection'

class RubyPlay < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :database, {adapter: 'sqlite3', database: 'ruby_play.sqlite3'}
  set :views, Proc.new { File.join(root, "../views") }

  # just for debugging
  HOST = "10.42.0.136"
  USER = "pi"

  get '/' do
    erb :home
  end

  get '/users/:id' do
    @users = User.find_by_id(params[:id])
    @users.name
  end

  post "/new" do
    @user = User.new
    @user.name = params[:user_name]
    success = @user.save!
    if success
      redirect "users/#{@user.id}"
    else
      erb :new
    end
  end

  get '/file_upload' do
    erb :file_upload
  end

  # uploads a song
  post '/file' do
    @audio_file = AudioFile.new
    @audio_file.title, @audio_file.original_title, @audio_file.file = make_params_upload(params)
    success = @audio_file.save
    if success
        { :status => "OK"}.to_json
    else
        { :status => "NOK"}.to_json
    end
  end

  # Displays all songs
  get '/files' do
    @audio_files = AudioFile.all
    erb :all_audio_files
  end

  #Plays a song
  post '/files' do
    play_song(params)
    redirect '/files'
  end

  get '/pause_song' do
    pause_song
    redirect '/files'
  end

  get '/stop_song' do
    stop_song
    redirect '/files'
  end

  def play_song(params)
    id = params[:picked_song].split(" ").first.to_i
    audio_file = AudioFile.find(id)
    path = make_path(id, audio_file)

    ssh = SSHConnector.new(HOST, USER, [])
    ssh.upload_song(path, audio_file.title)
    Thread.new { ssh.play_song(audio_file.title) }
  end

  def make_path(id, audio_file)
    "./public/system/files/#{id}/original/" + audio_file.file_file_name + '.'
  end

  def pause_song
    SSHConnector.new(HOST, USER, []).pause_song
  end

  def stop_song
    SSHConnector.new(HOST, USER, []).stop_song
  end

  def make_params_upload(params)
    #title, original title, file
    [URI.escape(params[:file][:filename].gsub(' ', '')),
    params[:file][:filename],
    params[:file][:tempfile]]
  end
end
#@filename = params[:file][:filename]
    #params[:photo][:image] = params[:photo][:image][:tempfile] if params[:photo][:image]
