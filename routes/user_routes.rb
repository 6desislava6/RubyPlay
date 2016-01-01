require 'sinatra/base'
require 'sinatra/activerecord'
require './models/User'
require './models/AudioFile'
require './models/Playlist'
require './models/Playlistable'
require 'paperclip'
require 'warden'
require 'sinatra/flash'
require_relative '../controllers/ssh_connection'

class RubyPlay < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :database, {adapter: 'sqlite3', database: 'ruby_play.sqlite3'}
  set :views, Proc.new { File.join(root, "../views") }
  set :public, Proc.new { File.join(root, "../public") }

  enable :sessions
  register Sinatra::Flash

  GlobalState = {}
  GlobalState[:now_playing] = nil

  use Warden::Manager do |config|
    config.serialize_into_session{|user| user.id }
    config.serialize_from_session{|id| User.find(id) }
    config.scope_defaults :default,
      strategies: [:password],
      action: 'auth'
    config.failure_app = self
  end

  Warden::Manager.before_failure do |env,opts|
    env['REQUEST_METHOD'] = 'POST'
  end


  Warden::Strategies.add(:password) do
    def authenticate!
      user = User.find_by(email: params['email'])
      if user.nil?
        fail!("The username you entered does not exist.")
      elsif user.authenticate(params['password'])
        success!(user)
      else
        fail!("Could not log in")
      end
    end
  end

  post '/login' do
    env['warden'].authenticate!
    flash[:success] = env['warden'].message
    if session[:return_to].nil?
      redirect '/now_playing'
    else
      redirect session[:return_to]
    end
  end

  get '/logout' do
    env['warden'].raw_session.inspect
    env['warden'].logout
    flash[:success] = 'Successfully logged out'
    redirect '/'
  end

  post '/unauthenticated' do
    session[:return_to] = env['warden.options'][:attempted_path]
    puts env['warden.options'][:attempted_path]
    flash[:error] = env['warden'].message || "You must log in"
    redirect '/login'
  end

  post "/auth" do
    login_greeting = env['warden'].authenticated? ?
                    "welcome #{env['warden'].user}!" :
                    "not logged in :( sorry"
  end

  # just for debugging
  HOST = "10.42.0.136"
  USER = "pi"

  get '/' do
    erb :home
  end

  post '/' do
    params.to_json
  end

  get '/users/:id' do
    @users = User.find_by_id(params[:id])
    @users.email
  end

  post "/new" do
    @user = User.new({ email: params[:email], password: params[:password] })
    success = @user.save!
    if success
      redirect "users/#{@user.id}"
    else
      erb :new
    end
  end

  # uploads a song
  post '/file' do
    @audio_file = AudioFile.new
    @audio_file.title, @audio_file.original_title, @audio_file.file = make_params_upload(params)
    @audio_file.user = env['warden'].user
    success = @audio_file.save
    if success
        { :status => "OK" }.to_json
    else
        { :status => "NOK" }.to_json
    end
  end
  # Displays all songs
  get '/now_playing' do
    @user = env['warden'].user
    @audio_files = GlobalState[:now_playing].nil? ? @user.audio_files : GlobalState[:now_playing]
    erb :all_audio_files
  end

  get '/all' do
    GlobalState[:now_playing] = env['warden'].user.audio_files
    redirect '/now_playing'
  end

  #Plays a song
  post '/play_song' do
    play_song(params)
    redirect '/now_playing'
  end

  get '/pause_song' do
    pause_song
    redirect '/now_playing'
  end

  get '/stop_song' do
    stop_song
    redirect '/now_playing'
  end

  get '/make_playlist' do
    @user = env['warden'].user
    @audio_files = @user.audio_files
    erb :make_playlist
  end

  post '/make_playlist' do
    name = JSON.parse(params.to_json)['name']
    ids = JSON.parse(params.to_json)['picked_songs'].map(&:to_i)
    audio_files = AudioFile.all.select { |file| ids.include? file.id }
    make_playlist(audio_files, name)
    redirect '/playlists'
  end

  get '/playlists' do
    @user = env['warden'].user
    @playlists = @user.playlists
    erb :playlists
  end

  post '/playlists' do
    @user = env['warden'].user
    @playlist = Playlist.find(params['picked_playlist'])
    @audio_files = @playlist.audio_files
    GlobalState[:now_playing] = @audio_files
    erb :all_audio_files
  end

  post '/search' do
    searched = params[:search]
    @user = env['warden'].user
    @audio_files = @user.audio_files.select do |file|
     (file.title.include? searched) or (searched.include? file.title)
    end
    erb :searched
  end

  def make_playlist(audio_files, name)
    playlist = Playlist.new(user: env['warden'].user, name: name)
    audio_files.each do |file|
      playlistable = Playlistable.new
      playlistable.audio_file = file
      playlistable.playlist = playlist
      playlistable.save!
    end
    playlist.save!
  end

  def play_song(params)
    stop_song
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
    #halt 401, "Not authorized\n" if !env['warden'].authenticated?
