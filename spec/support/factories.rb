require 'factory_girl'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end

FactoryGirl.define do
  factory :user do
    email 'test@example.com'
    password 'f4k3p455w0rd'
  end
end
