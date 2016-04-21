class Institute < ActiveRecord::Base

  has_many :schools, dependent: :destroy
  has_many :residents, through: :schools
  has_many :reservations, through: :residents
  has_many :tags, through: :residents

  validates_presence_of     :name
  validates_uniqueness_of   :name

  log_after :create, :update, :destroy

  def self.options_for_select(hash = {})
    arr = find(:all, order_by: :name).map { |i| [i.name, i.id] }
    arr.unshift([hash[:text] || 'All', nil]) if hash[:allow_nil]
    arr
  end

  def to_s
    name
  end
end
