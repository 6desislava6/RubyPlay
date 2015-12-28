class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.references :audio_files
      t.references :playlists
      t.timestamps
    end
  end

  def down
    drop_table :users
  end
end
