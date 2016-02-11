# https://github.com/thoughtbot/factory_girl/blob/master/GETTING_STARTED.md

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    FactoryGirl.find_definitions
  end
end

FactoryGirl.define do
  factory :user do
    email "aa@aa.aa"
    password "123456"
    created_at "2016-02-10 15:09:33.526634"
    updated_at "2016-02-10 15:09:33.526634"
  end
end
