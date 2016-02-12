require 'paperclip'

class AudioFile < ActiveRecord::Base
  include Paperclip::Glue
  belongs_to :user
  #belongs_to :songable, polymorphic: true
  has_many :playlistables
  has_many :playlists, :through => :playlists

  #config.active_record.raise_in_transactional_callbacks = true

  has_attached_file :file, :preserve_files => "false",
                    :url => "./system/:attachment/:id/:style/:basename.:extension",
                    :path => "./public/system/:attachment/:id/:style/:basename.:extension"

  validates_attachment_content_type :file, :content_type => [ 'audio/mpeg',
   'audio/x-mpeg', 'audio/mp3', 'audio/x-mp3', 'audio/mpeg3',
   'audio/x-mpeg3', 'audio/mpg', 'audio/x-mpg', 'audio/x-mpegaudio' ]

  before_destroy do |record|
    FileUtils.rm_rf("system/file/#{id}/original/#{record.file.file_file_name}.")
  end
end
