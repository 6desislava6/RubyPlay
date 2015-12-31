class Playlistable < ActiveRecord::Base
  belongs_to :audio_file
  belongs_to :playlist
end
