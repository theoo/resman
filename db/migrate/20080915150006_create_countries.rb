class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.integer :continent_id, null: false
      t.string  :name, null: false
      t.timestamps
    end

    add_index :countries, :continent_id
  end

  def self.down
    drop_table :countries
  end
end
