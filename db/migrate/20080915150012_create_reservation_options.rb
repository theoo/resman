class CreateReservationOptions < ActiveRecord::Migration
  def self.up
    create_table :reservation_options do |t|
      t.integer :reservation_id, null: false
      t.integer :room_option_id, null: false
      t.timestamps
    end

    add_index :reservation_options, :reservation_id
    add_index :reservation_options, :room_option_id
  end

  def self.down
    drop_table :reservation_options
  end
end
