class CreateRights < ActiveRecord::Migration
  def self.up
    create_table :rights do |t|
      t.integer :group_id, null: false
      t.string  :controller, null: false
      t.string  :action, null: false
      t.boolean :allowed
      t.timestamps
    end

    add_index :rights, :group_id
  end

  def self.down
    drop_table :rights
  end
end
