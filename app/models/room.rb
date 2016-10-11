class Room < ActiveRecord::Base

  Status = %w{ available work_in_progress }

  scope :visibles, -> { where(visible: true) }
  scope :hiddens, -> { where(visible: false) }

  belongs_to  :building
  belongs_to  :rate

  has_many    :reservations,
    dependent: :destroy
  has_many    :options,
    class_name: 'RoomOption',
    dependent: :destroy
  has_many    :comments,
    as: :entity,
    dependent: :destroy

  validates_presence_of     :building_id
  validates_presence_of     :rate_id
  validates_presence_of     :name
  validates_uniqueness_of   :name, scope: :building_id
  validates_numericality_of :size, allow_nil: true

  log_after :create, :update, :destroy

  def self.options_for_select(hash = {})
    arr = order(:name).map { |r| [r.name, r.id] }
    arr.unshift([hash[:text] || 'All', nil]) if hash[:allow_nil]
    arr
  end

  def self.available_rooms(start_date, end_date, rooms_to_include = nil)
    return all unless start_date && end_date
    return [] if start_date >= end_date

    # TODO perfs, user Room.joins(:reservations) instead
    # TODO remove once tested
    # find_all, conditions: { arrival_lt: end_date, departure_gt: start_date, status_ne: 'cancelled' })
    reservations = Reservation
      .where("arrival < ? AND ? < departure", end_date, start_date)
      .where.not(status: 'cancelled')
    reserved_rooms = reservations.map(&:room)

    if rooms_to_include
      rooms_to_include = [rooms_to_include] if rooms_to_include.is_a?(Room)
      reserved_rooms -= rooms_to_include
    end

    all - reserved_rooms
  end

  def deletable?
    self.reservations.empty?
  end

  def to_s
    name
  end

end
