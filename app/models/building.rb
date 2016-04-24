class Building < ActiveRecord::Base
  has_many  :rooms,
    dependent: :destroy
  has_many  :reservations,
    through: :rooms

  validates_presence_of     :name
  validates_uniqueness_of   :name

  log_after :create, :update, :destroy

  def self.options_for_select(hash = {})
    arr = all.order(:name).map { |b| [b.name, b.id] }
    arr.unshift([hash[:text] || 'All', nil]) if hash[:allow_nil]
    arr
  end

  def deletable?
    self.rooms.each do |room|
      return false unless room.reservations.empty?
    end
    true
  end
end
