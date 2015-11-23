class CreateResidents < ActiveRecord::Migration
  def self.up
    create_table :residents do |t|
      t.integer :country_id
      t.integer :religion_id
      t.integer :school_id
      t.string  :color, default: 'ffff00'
      t.string  :first_name, null: false
      t.string  :last_name, null: false
      t.string  :gender
      t.date    :birthdate
      t.string  :address
      t.string  :email
      t.string  :phone
      t.string  :mobile
      t.string  :mac_address
      t.boolean :mac_active
      t.string  :identity_card
      t.string  :bank_name
      t.string  :bank_iban
      t.string  :bank_bic_swift
      t.string  :bank_clearing
      t.timestamps
    end

    add_index :residents, :country_id
    add_index :residents, :religion_id
    add_index :residents, :school_id
  end

  def self.down
    drop_table :residents
  end
end