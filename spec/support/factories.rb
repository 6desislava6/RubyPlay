require 'factory_girl'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

FactoryGirl.define do
  factory :user do
    email 'test@example.com'
    password 'f4k3p455w0rd'
  end

  factory :audio_file do
    user_id 1
    original_title  'Mine'
    title  'Mine'
    file { File.new('./spec/file_upload/Mine.mp3') }
    factory :audio_file_second do
      original_title 'Mine 2'
      title 'Mine 2'
    end
  end


  factory :raspberry do
    host 'host'
    name 'name'
    user_id 1
  end

end
