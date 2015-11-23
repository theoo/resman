# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

YAML.load_file("#{Rails.root}/db/seeds/rights.yml").each do |i|
  if Right.where(i).count == 0
    right = Right.create(i)
    raise ArgumentError, i.inspect if right.errors.size > 0
  end
end