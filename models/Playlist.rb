class Playlist < ActiveRecord::Base
  belongs_to :user
  has_many :audio_files
end
