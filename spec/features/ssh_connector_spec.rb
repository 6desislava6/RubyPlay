require 'net/ssh'

describe SSHConnector do
  let (:ssh_connection) { double("SSHConnection") }

  before (:each) do
    Net::SSH.stub(:start)
    @ssh_connector = SSHConnector.new('host', 'user', [])
    @ssh_connector.pause_song

  end

=begin
  it "pauses a song" do
    Net::SSH.start('@host', '@user') do |ssh|
      ssh.exec! 'echo -n p >fifo'
    end
    ssh_mock = double
    expect(Net::SSH).to receive('start').and_yield(ssh_mock)
    expect(ssh_mock).to receive(:exec!).with('echo -n p >fifo')
  end
=end
end
