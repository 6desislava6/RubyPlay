class CreatePlaylistables < ActiveRecord::Migration
  def change
    create_table :playlistables do |t|
      t.integer :playlist_id
      t.integer :audio_file_id
    end
  end
end
