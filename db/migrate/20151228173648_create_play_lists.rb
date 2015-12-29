class CreatePlayLists < ActiveRecord::Migration
  def change
    create_table :playlists do |t|
      t.belongs_to :user
      t.string :name
      t.timestamps
    end
  end

  def down
    drop_table :playlists
  end
end
