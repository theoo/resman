class CreateSchools < ActiveRecord::Migration
  def self.up
    create_table :schools do |t|
      t.integer :institute_id, null: false
      t.string  :name, null: false
      t.timestamps
    end

    add_index :schools, :institute_id
  end

  def self.down
    drop_table :schools
  end
end
