require 'sinatra/base'
require 'sinatra/activerecord'
require './models/User'
require './models/AudioFile'
require './models/Playlist'
require 'paperclip'
require 'warden'
require 'sinatra/flash'


require_relative '../controllers/ssh_connection'

class RubyPlay < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :database, {adapter: 'sqlite3', database: 'ruby_play.sqlite3'}
  set :views, Proc.new { File.join(root, "../views") }

  enable :sessions
  register Sinatra::Flash

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
      redirect '/files'
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
                    "not logged in"
  end

  # just for debugging
  HOST = "10.42.0.136"
  USER = "pi"

  get '/' do
    erb :home
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
        { :status => "OK"}.to_json
    else
        { :status => "NOK"}.to_json
    end
  end

  # Displays all songs
  get '/files' do
    @audio_files = AudioFile.all.select { |file| file.user == env['warden'].user }
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
