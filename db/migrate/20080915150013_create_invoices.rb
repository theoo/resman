class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.integer :parent_id
      t.integer :reservation_id, null: false
      t.boolean :closed
      t.date    :interval_start
      t.date    :interval_end
      t.string  :type
      t.timestamps
    end

    add_index :invoices, :parent_id
    add_index :invoices, :reservation_id
  end

  def self.down
    drop_table :invoices
  end
end
