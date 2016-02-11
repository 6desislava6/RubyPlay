require "sinatra/activerecord"
require 'bcrypt'

class Raspberry < ActiveRecord::Base
  belongs_to :user
end
