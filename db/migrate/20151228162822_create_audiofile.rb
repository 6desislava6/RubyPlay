class CreateAudiofile < ActiveRecord::Migration
  def change
    create_table :audio_files do |t|
      t.belongs_to :user
      t.string :title
      t.string :artist
      t.string :duration
      t.string :original_title
      #t.name :name
      t.timestamps
    end
    add_attachment :audio_files, :file

  end

  def down
    drop_table :audio_files
    remove_attachment :audio_files, :file
  end
end
