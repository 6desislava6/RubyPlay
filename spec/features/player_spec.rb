require 'spec_helper'

describe Player do
  let(:ssh_connection) { double('ssh_connection') }

  before do
    @player = Player.new('host', 'pi')
    @audio_file = FactoryGirl.create(:audio_file)
    @player.ssh_connection = ssh_connection
  end

  it 'player plays a songs' do
    ssh_connection.should_receive('stop_song')
    ssh_connection.should_receive('upload_song')
                  .with("./public/system/files/1/original/Mine.mp3.", "Mine")

    ssh_connection.should_receive('play_song')
    params = { picked_song: "1" }
    @player.play_song(params)
  end

  it 'player pauses a songs' do
    ssh_connection.should_receive('pause_song')
    @player.pause_song
  end

  it 'player stops a songs' do
    ssh_connection.should_receive('stop_song')
    @player.stop_song
  end

  it 'player boosts up volume' do
    ssh_connection.should_receive('sound_up')
    @player.sound_up
  end

  it 'player boosts down volume' do
    ssh_connection.should_receive('sound_down')
    @player.sound_down
  end

  it 'player deletes files' do
    ssh_connection.should_receive('delete_audiofiles')
    @player.delete_audiofiles
  end
end
