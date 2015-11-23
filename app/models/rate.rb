class Rate < ActiveRecord::Base
  has_many    :rooms
  has_many    :rules, order: 'start_type, start_value', dependent: :destroy

  validates_presence_of     :name
  validates_uniqueness_of   :name

  def deletable?
    self.rooms.empty?
  end

  def usable?
    return true
    # TODO implement me and use me for rate assignments
    intervals = self.rules.collect{ |r| r.interval_range }
  end

  def self.options_for_select(hash = {})
    arr = find(:all, order_by: :name).select{ |r| r.usable? }.map{ |r| [r.name, r.id] }
    arr.unshift([hash[:text] || 'All', nil]) if hash[:allow_nil]
    arr
  end
end
