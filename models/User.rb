require "sinatra/activerecord"

class User < ActiveRecord::Base
  validates_presence_of :name
  has_many :audio_files
  has_many :playlists
end
