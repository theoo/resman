class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :user_id, null: false
      t.string  :title, null: false
      t.text    :text, null: false
      t.boolean :read, default: false
      t.integer :entity_id, null: false
      t.string  :entity_type, null: false
      t.timestamps
    end

    add_index :comments, :user_id
    add_index :comments, :entity_id
    add_index :comments, :entity_type
  end

  def self.down
    drop_table :comments
  end
end
