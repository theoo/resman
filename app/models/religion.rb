class Religion < ActiveRecord::Base

  has_many :residents, dependent: :nullify
  has_many :reservations, through: :residents
  has_many :tags, through: :residents

  validates_presence_of     :name
  validates_uniqueness_of   :name

  log_after :create, :update, :destroy

  def self.options_for_select(hash = {})
    arr = all.order(:name).map { |r| [r.name, r.id] }
    arr.unshift([hash[:text] || 'All', nil]) if hash[:allow_nil]
    arr
  end

  def to_s
    name
  end
end
