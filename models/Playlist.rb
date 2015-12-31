class Playlist < ActiveRecord::Base
  belongs_to :user
  has_many :playlistables
  has_many :audio_files, :through => :playlistables
  #has_many :audio_files, as: :songable
end
