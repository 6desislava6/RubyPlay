require './models/Playlist'
require './models/Playlistable'
require './models/AudioFile'
require_relative './ssh_connection'

class Player

  attr_accessor :ssh_connection

  def initialize(host_raspberry, user_raspberry)
    @host = host_raspberry
    @user = user_raspberry
    @ssh_connection = SSHConnector.new(@host, @user, [])
  end

  def make_playlist(audio_files, name, user)
    playlist = Playlist.new(user: user, name: name)
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
    @ssh_connection.upload_song(path, audio_file.title)
    Thread.new { @ssh_connection.play_song(audio_file.title) }
  end

  def make_path(id, audio_file)
    "./public/system/files/#{id}/original/" + audio_file.file_file_name + '.'
  end

  def pause_song
    @ssh_connection.pause_song
  end

  def stop_song
    @ssh_connection.stop_song
  end

  def sound_down
    @ssh_connection.sound_down
  end

  def sound_up
    @ssh_connection.sound_up
  end

  def delete_audiofiles
    @ssh_connection.delete_audiofiles
  end
end

