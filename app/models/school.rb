class School < ActiveRecord::Base

  has_many   :residents, dependent: :nullify
  belongs_to :institute
  has_many   :reservations, through: :residents
  has_many   :tags, through: :residents

  validates_presence_of     :institute_id
  validates_presence_of     :name
  validates_uniqueness_of   :name, scope: :institute_id

  log_after :create, :update, :destroy

  def self.options_for_select(hash = {})
    arr = all.order([:institute_id, :name]).map { |s| ["#{s.institute.name} #{s.name}", s.id] }
    arr.unshift([hash[:text] || 'All', nil]) if hash[:allow_nil]
    arr
  end

  def to_s
    name
  end
end
