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
    redirect_not_logged_in
    env['warden'].raw_session.inspect
    env['warden'].logout
    begin
      GlobalState[:player].delete_audiofiles # if !GlobalState[:player].nil?
    rescue Errno::EINVAL => e
    else
      flash[:success] = 'Successfully logged out'
    ensure
      redirect '/'
    end
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
    redirect_not_logged_in
    @users = User.find_by_id(params[:id])
    @users.email
  end

  post "/new" do
    @user = User.new({ email: params[:email], password: params[:password] })
    begin
      @user.save!
      erb :messages_layout, :layout => false do
        erb :success_register
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
        redirect '/now_playing'
    else
        { :status => "NOK" }.to_json
    end
  end

  get '/now_playing' do
    redirect_not_logged_in
    @user = env['warden'].user

    @audio_files = GlobalState[:now_playing].nil? ? @user.audio_files : GlobalState[:now_playing]
    @size = @audio_files.reduce(0) { |size, song| size + song.file_file_size }
    @size /= 2 ** 20
    erb :main_layout, :layout => false do
      erb :all_audio_files
    end
  end

  get '/all' do
    redirect_not_logged_in
    GlobalState[:now_playing] = env['warden'].user.audio_files
    redirect '/now_playing'
  end

  post '/play_song' do
    redirect_not_logged_in

    GlobalState[:player].play_song(params)
    redirect '/now_playing'
  end

  get '/pause_song' do
    redirect_not_logged_in
    GlobalState[:player].pause_song
    redirect '/now_playing'
  end

  get '/sound_down' do
    redirect_not_logged_in
    GlobalState[:player].sound_down
    redirect '/now_playing'
  end

  get '/sound_up' do
    redirect_not_logged_in
    GlobalState[:player].sound_up
    redirect '/now_playing'
  end

  get '/stop_song' do
    redirect_not_logged_in
    GlobalState[:player].stop_song
    redirect '/now_playing'
  end

  get '/make_playlist' do
    redirect_not_logged_in
    @user = env['warden'].user
    @audio_files = @user.audio_files
    erb :main_layout, layout: false do
      erb :make_playlist
    end
  end

  post '/make_playlist' do
    name = JSON.parse(params.to_json)['name']
    ids = JSON.parse(params.to_json)['picked_songs']
    redirect '/make_playlist' if name.nil? or ids.nil?

    ids = JSON.parse(params.to_json)['picked_songs'].map(&:to_i)
    audio_files = AudioFile.all.select { |file| ids.include? file.id }
    GlobalState[:player].make_playlist(audio_files, name, env['warden'].user)
    redirect '/playlists'
  end

  get '/playlists' do
    redirect_not_logged_in
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
    redirect_not_logged_in
    @user = env['warden'].user
    @raspberry = Raspberry.find_by(user_id: env['warden'].user.id)
    page = @raspberry.nil? ? :register_raspberry : :display_raspberry
    erb :main_layout, layout: false do
      erb page
    end
  end

  post '/register_raspberry' do
    @user = env['warden'].user

    host, user, password = params[:host], params[:user], params[:password]
    make_raspberry(@user, host, user)

    SSHRegisterRaspberry.register_raspberry(host, user, password)
    erb :messages_layout, layout: false do
      erb :success_register_raspberry
    end
  end

  before do
    return if  env['warden'].user.nil?
    if GlobalState[:player].nil?
      raspberry = Raspberry.find_by(user_id: env['warden'].user.id)
      return if raspberry.nil?
      GlobalState[:player] = Player.new(raspberry.host, raspberry.name)
    end
  end

  not_found do
    status 404
    @return_link = '/'
    erb :not_found404
  end

  def make_raspberry(user, host, user_name)
    raspberry = Raspberry.new(host: host, name: user_name, user: user)
    raspberry.user = user
    raspberry.save
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
