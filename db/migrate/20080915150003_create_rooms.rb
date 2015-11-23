class CreateRooms < ActiveRecord::Migration
  def self.up
    create_table :rooms do |t|
      t.integer :building_id
      t.integer :rate_id
      t.string  :name, null: false
      t.integer :size
      t.string  :phone
      t.string  :status, null: false
      t.timestamps
    end

    add_index :rooms, :building_id
    add_index :rooms, :rate_id
  end

  def self.down
    drop_table :rooms
  end
end
