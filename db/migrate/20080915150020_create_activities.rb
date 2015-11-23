class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.integer :user_id, null: false
      t.string  :text, null: false
      t.integer :entity_id, null: false
      t.string  :entity_type, null: false
      t.timestamps
    end

    add_index :activities, :user_id
    add_index :activities, :entity_id
    add_index :activities, :entity_type
  end

  def self.down
    drop_table :activities
  end
end
