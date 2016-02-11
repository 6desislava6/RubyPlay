require 'net/scp'
require 'net/ssh'

# Registers the raspberry
class SSHRegisterRaspberry
  TEMPLATE = "cat ~/.ssh/id_rsa.pub | sshpass -p %{password} ssh %{user}@%{host} 'cat >> .ssh/authorized_keys'"
  class << self
    def register_raspberry(host, user, password)
      p TEMPLATE % { user: user, host: host, password: password }
      command = system(TEMPLATE % { user: user, host: host, password: password })
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
    remove_fifo
  end

  def pause_song
    Net::SSH.start(@host, @user) do |ssh|
      ssh.exec! 'echo -n p >fifo'
    end
  end

  def sound_down
    Net::SSH.start(@host, @user) do |ssh|
      ssh.exec! 'echo -n - >fifo'
    end
  end

  def sound_up
    Net::SSH.start(@host, @user) do |ssh|
      ssh.exec! 'echo -n + >fifo'
    end
  end

  def stop_song
    Net::SSH.start(@host, @user) do |ssh|
      ssh.exec! 'echo -n q >fifo'
    end
    remove_fifo
  end

  def make_fifo
    Net::SSH.start(@host, @user) do |ssh|
      ssh.exec 'if test -e "fifo";then  rm fifo; fi'
      ssh.exec 'mkfifo fifo'
    end
  end

  def remove_fifo
    Net::SSH.start(@host, @user)do |ssh|
      ssh.exec 'if test -e "fifo";then  rm fifo; fi'
    end
  end

  def delete_audiofiles
    begin
      Net::SSH.start(@host, @user, timeout: 3)do |ssh|
        ssh.exec 'rm ./Desi/*'
      end
    rescue Net::SSH::ConnectionTimeout => e
      return
    end
  end
end
