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
require_relative '../controllers/player'
require_relative '../helpers/SiteHelper'


class RubyPlay < Sinatra::Base
  helpers SiteHelper
  register Sinatra::ActiveRecordExtension
  set :database, { adapter: 'sqlite3', database: 'ruby_play.sqlite3' }
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
      action: 'unauthenticated'
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
    authenticated = env['warden'].authenticate!
    flash[:success] = env['warden'].message
    if session[:return_to].nil? or authenticated
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
    redirect '/', 307
  end

  get '/' do
    if env['warden'].user.nil?
      erb :home_layout, :layout => false do
        ''
      end
    else
      redirect '/now_playing'
    end
  end

  post '/' do
    erb :home_layout, :layout => false do
      erb :unsuccessful_login
    end
  end

  get '/users/:id' do
    @users = User.find_by_id(params[:id])
    @users.email
  end

  post "/new" do
    @user = User.new({ email: params[:email], password: params[:password] })
    begin
      success = @user.save!
      if success
        redirect "users/#{@user.id}"
      else
        erb :new
      end
    rescue ActiveRecord::RecordInvalid => invalid
      redirect '/invalid_user'
    end
  end

  get '/invalid_user' do
    erb :invalid_user
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

  get '/now_playing' do
    redirect_not_logged_in
    @user = env['warden'].user

    @audio_files = GlobalState[:now_playing].nil? ? @user.audio_files : GlobalState[:now_playing]
    erb :main_layout, :layout => false do
      erb :all_audio_files
    end
  end

  get '/all' do
    GlobalState[:now_playing] = env['warden'].user.audio_files
    redirect '/now_playing'
  end

  post '/play_song' do
    Player.play_song(params)
    redirect '/now_playing'
  end

  get '/pause_song' do
    Player.pause_song
    redirect '/now_playing'
  end

  get '/sound_down' do
    Player.sound_down
    redirect '/now_playing'
  end

  get '/sound_up' do
    Player.sound_up
    redirect '/now_playing'
  end

  get '/stop_song' do
    Player.stop_song
    redirect '/now_playing'
  end

  get '/make_playlist' do
    @user = env['warden'].user
    @audio_files = @user.audio_files
    erb :main_layout, layout: false do
      erb :make_playlist
    end
  end

  post '/make_playlist' do
    name = JSON.parse(params.to_json)['name']
    ids = JSON.parse(params.to_json)['picked_songs'].map(&:to_i)
    audio_files = AudioFile.all.select { |file| ids.include? file.id }
    Player.make_playlist(audio_files, name, env['warden'].user)
    redirect '/playlists'
  end

  get '/playlists' do
    @user = env['warden'].user
    @playlists = @user.playlists
    erb :main_layout, :layout => false do
      erb :playlists
    end
  end

  post '/playlists' do
    @user = env['warden'].user
    playlist = Playlist.find(params['picked_playlist'])
    @audio_files = playlist.audio_files
    GlobalState[:now_playing] = @audio_files
    redirect '/now_playing'
  end

  post '/search' do
    searched = params[:search]
    @user = env['warden'].user
    @audio_files = @user.audio_files.select do |file|
     (file.title.include? searched) or (searched.include? file.title)
    end
    erb :main_layout, layout: false do
      erb :searched
    end

  end

  get '/register_raspberry' do
    @user = env['warden'].user
    erb :main_layout, layout: false do
      erb :register_raspberry
    end
  end

  post '/register_raspberry' do
    @user = env['warden'].user
    host, user, password = params[:host], params[:user], params[:password]
    SSHRegisterRaspberry.register_raspberry(host, user, password)
  end

  def make_params_upload(params)
    [URI.escape(params[:file][:filename].gsub(' ', '')),
    params[:file][:filename],
    params[:file][:tempfile]]
  end

  def redirect_not_logged_in
    if env['warden'].user.nil?
      redirect '/'
    end
  end
end
