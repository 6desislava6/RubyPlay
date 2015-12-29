class CreateAudiofile < ActiveRecord::Migration
  def change
    create_table :audio_files do |t|
      t.belongs_to :user
      t.string :title
      t.string :artist
      t.string :duration
      t.name :name
      t.timestamps
    end
  end

  def down
    drop_table :audio_files
  end
end
