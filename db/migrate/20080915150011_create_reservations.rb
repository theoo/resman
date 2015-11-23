class CreateReservations < ActiveRecord::Migration
  def self.up
    create_table :reservations do |t|
      t.integer :resident_id, null: false
      t.integer :room_id, null: false
      t.string  :status, null: false, default: 'pending'
      t.date    :arrival, null: false
      t.date    :departure, null: false
      t.timestamps
    end

    add_index :reservations, :resident_id
    add_index :reservations, :room_id
  end

  def self.down
    drop_table :reservations
  end
end
