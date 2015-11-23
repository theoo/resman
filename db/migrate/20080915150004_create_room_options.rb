class CreateRoomOptions < ActiveRecord::Migration
  def self.up
    create_table :room_options do |t|
      t.integer :room_id, null: false
      t.string  :name, null: false
      t.integer :value_in_cents, null: false, default: 0
      t.string  :billing, null: false
      t.timestamps
    end

    add_index :room_options, :room_id
  end

  def self.down
    drop_table :room_options
  end
end
