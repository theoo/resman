class CreateIncomes < ActiveRecord::Migration
  def self.up
    create_table :incomes do |t|
      t.integer :invoice_id, null: false
      t.integer :value_in_cents, null: false, default: 0
      t.string  :payment, null: false
      t.date    :received, null: false
      t.timestamps
    end

    add_index :incomes, :invoice_id
  end

  def self.down
    drop_table :incomes
  end
end
