require 'net/scp'
require 'net/ssh'

# Registers the raspberry
class SSHRegisterRaspberry

  TEMPLATE = "cat ~/.ssh/id_rsa.pub | ssh %{user}@%{host} 'cat >> .ssh/authorized_keys'"
  class << self
    def register_raspberry(host, user, password)
      Net::SSH.start(host, user, password: password) do |ssh|
        ssh.exec TEMPLATE % { user: user, host: host }
      end
    end
  end
  # after registering the raspberry no more passwords will be required
end

# Connects the raspberry to the server
class SSHConnector

  def initialize(host, user, keys)
    @host = host
    @user = user
    @keys = keys
  end

  def upload_song(local_name, dest_name)
    # .start(@host, @user,  :key_data => @keys, :keys_only => TRUE)
    puts "EHOOOOOOOOOOOOOOOOOOOOo" + Dir.pwd
    p Dir.pwd
    Net::SCP.start(@host, @user) do |scp|
      channel = scp.upload local_name, "./Desi/#{dest_name}"
      channel.wait
    end
  end

  def play_song(song_name)
    make_fifo
    Net::SSH.start(@host, @user) do |ssh|
      ssh.exec "omxplayer -o local ./Desi/#{song_name} <fifo &"
      ssh.exec 'echo -n "" > fifo'
    end
  end

  def pause_song
    Net::SSH.start(@host, @user) do |ssh|
      ssh.exec 'echo -n p >fifo'
    end
  end

  def stop_song
    Net::SSH.start(@host, @user) do |ssh|
      ssh.exec 'echo -n q >fifo'
    end
    remove_fifo
  end

  def make_fifo
    Net::SSH.start(@host, @user) do |ssh|
      ssh.exec 'mkfifo fifo'
    end
  end

  def remove_fifo
    Net::SSH.start(@host, @user)do |ssh|
      ssh.exec 'rm fifo'
    end
  end
end

'
HOST = "10.42.0.136"
USER = "pi"

#KEYS = [File.read("key")[0..-2]]
KEYS = []


ssh = SSHConnector.new(HOST, USER, KEYS)
ha = "winner.jpg"
ssh.upload_song(ha, ha)

#ha = "song.sh"
#ssh.upload_song(ha, ha)
th = Thread.new {ssh.play_song( "Dawin-Dessert.mp3")}
sleep 10
ssh.pause_song
#puts "paused!"
ssh.pause_song
sleep 3
ssh.stop_song'
#th.join


