class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer   :invoice_id, null: false
      t.string    :name, null: false
      t.integer   :value_in_cents, null: false
      t.timestamps
    end

    add_index :items, :invoice_id
  end

  def self.down
    drop_table :items
  end
end
