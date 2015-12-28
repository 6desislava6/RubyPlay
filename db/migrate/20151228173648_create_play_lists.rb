class CreatePlayLists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
      t.string :title
      t.references :user
      t.references :audio_files
      t.timestamps
    end
  end

  def down
    drop_table :playlists
  end
end
