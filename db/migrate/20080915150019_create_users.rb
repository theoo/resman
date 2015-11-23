class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :group_id, null: false
      t.string  :login, null: false
      t.string  :password_hash, null: false
      t.string  :first_name
      t.string  :last_name
      t.string  :email
      t.string  :phone
      t.string  :mobile
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
