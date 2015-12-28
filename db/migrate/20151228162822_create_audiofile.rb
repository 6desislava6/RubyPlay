class CreateAudiofile < ActiveRecord::Migration
  def change
    create_table :audio_files do |t|
      t.string :title
      t.references :user
      t.timestamps
    end
  end

  def down
    drop_table :audio_files
  end
end
