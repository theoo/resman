class MonetizeTables < ActiveRecord::Migration
  def change
    add_column :rules, :value_currency, :string, null: false, default: "CHF"
    add_column :room_options, :value_currency, :string, null: false, default: "CHF"
    add_column :incomes, :value_currency, :string, null: false, default: "CHF"
    add_column :items, :value_currency, :string, null: false, default: "CHF"
  end
end
