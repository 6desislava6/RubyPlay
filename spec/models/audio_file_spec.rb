require 'spec_helper'

describe AudioFile do

  it 'has a valid factory' do
    FactoryGirl.create(:audio_file).should be_valid
  end

  it 'validates audio file\'s format' do
    should validate_attachment_content_type(:file).allowing( 'audio/mpeg',
     'audio/x-mpeg', 'audio/mp3', 'audio/x-mp3', 'audio/mpeg3',
     'audio/x-mpeg3','audio/mpg', 'audio/x-mpg', 'audio/x-mpegaudio' )
  end
end
