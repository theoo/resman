class CreateRules < ActiveRecord::Migration
  def self.up
    create_table :rules do |t|
      t.integer :rate_id, null: false
      t.integer :start_value
      t.string  :start_type, null: false, default: 0
      t.integer :end_value
      t.string  :end_type, null: false, default: 0
      t.integer :value_in_cents, null: false, default: 0
      t.string  :value_type, null: false
      t.integer :tax_in_in_cents, null: false, default: 0
      t.integer :tax_out_in_cents, null: false, default: 0
      t.integer :deposit_in_in_cents, null: false, default: 0
      t.integer :deposit_out_in_cents, null: false, default: 0
      t.timestamps
    end

    add_index :rules, :rate_id
  end

  def self.down
    drop_table :rules
  end
end
