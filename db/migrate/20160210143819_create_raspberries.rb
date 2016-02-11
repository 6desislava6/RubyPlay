class CreateRaspberries < ActiveRecord::Migration
  def change
    create_table :raspberries do |t|
      t.belongs_to :user
      t.string :host
      t.string :name
    end
  end
end
