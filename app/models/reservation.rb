class Reservation < ActiveRecord::Base

  include ScopeExtention
  extend  ScopeExtention::ClassMethods

  Status = %w{ pending confirmed cancelled }

  scope :upcoming_checkin, -> (days = 7) {
    where("arrival BETWEEN ? AND ? AND status != 'cancelled'", Date.today, Date.today + days.day)
    .order('arrival ASC')
  }

  scope :upcoming_checkout, -> (days = 7) {
    where("departure BETWEEN ? AND ? AND status != 'cancelled'", Date.today, Date.today + days.day)
    .order('departure ASC')
  }

  scope :cancelled, -> { where(status: 'cancelled') }
  scope :actives, -> { where.not(status: 'cancelled') }

  # TODO compare
  scope :unbilled_reservations, -> (date = Date.today) {
    tag_to_ignore = Option.value('tag_to_ignore')

    ur = Reservation.joins(:resident, :tags)
      .where.not(status: 'cancelled')
      .where.not("tags.name" => tag_to_ignore)
      .where("arrival <= ?", date)
      .order("residents.last_name", "residents.first_name")
      .distinct

    # FIXME use cached value on reservation
    ur.to_a.reject!{ |r| r.arrival > date || r.reservation_invoices_generated?(r.arrival, date) }
    # FIXME return AREL object
  }

  belongs_to  :resident
  belongs_to  :room

  has_many :reservation_options,
    dependent: :destroy

  has_many :options,
    source: :room_option,
    through: :reservation_options

  has_many :invoices,
    -> { order('id ASC') },
    dependent: :destroy

  has_many :confirmation_invoices,
    -> { order('interval_start ASC') },
    dependent: :destroy

  has_many :reservation_invoices,
    -> { order('interval_start ASC') },
    dependent: :destroy

  has_many :deposit_invoices,
    -> { order('interval_start ASC') },
    dependent: :destroy

  has_many :incomes,
    through: :invoices

  has_many :comments,
    as: :entity,
    dependent: :destroy

  has_many :tags,
    through: :resident

  validate :validate_params
  validates_presence_of   :room_id
  validates_inclusion_of  :status, in: Status

  formatted_date :arrival, :departure
  log_after :create, :update, :destroy

  class << self

    def options_for_select(hash = {})
      arr = all.order([:room_id, :arrival]).map do |reservation|
        [reservation.to_s, reservation.id]
      end
      arr.unshift([hash[:text] || 'All', nil]) if hash[:allow_nil]
      arr
    end

  end

  def resident_full_name
    self.resident ? self.resident.full_name : nil
  end

  def resident_full_name=(str)
    self.resident = Resident.find_by_full_name(str) || Resident.new(full_name: str)
  end

  def options_attributes=(options_attributes)
    # FIXME eeeeeew ugly ship it
    self.reservation_options.each{ |o| o.destroy }
    options_attributes.each do |option_attributes|
      self.reservation_options.build(option_attributes)
    end
  end

  def rate_rule
    # Find the first rule that fits
    room.rate.rules.each do |rule|
      if rule.interval_end == Float::INFINITY or (arrival + rule.interval_end) > departure
        return rule
      end
    end
    raise 'Cannot find rule'
  end

  # TODO: make a DateRange class that has #to_s ?
  def interval_range
    self.arrival...self.departure
  end

  def interval_string
    "#{self.arrival_formatted} - #{self.departure_formatted}"
  end

  def days_in_common_with(date_start, date_end)
    range = (date_start..date_end) and self.interval_range
    range ? (range.last - range.first) : 0
  end

  def months_in_common_with(date_start, date_end)
    # TODO should rewrite this so it's not so inneficient :)
    range = (date_start..date_end) and self.interval_range
    arr = range.map{ |d| "#{d.month}-#{d.year}" }.uniq
    arr.size
  end

  def room_price(date_start, date_end)
    # Compute value
    rule = self.rate_rule
    rule.value * self.send("#{rule.value_type}s_in_common_with", date_start, date_end)
  end

  %w{ ConfirmationInvoice DepositInvoice }.each do |type|
    define_method("make_#{type.underscore}") do
      invoice = type.constantize.new(reservation: self, interval_start: self.arrival, interval_end: self.departure)
      invoice.compute_items
      invoice
    end

    define_method("#{type.underscore}") do
      self.send("#{type.underscore}s").first
    end

    define_method("#{type.underscore}_generated?") do
      self.send(type.underscore) != nil
    end
  end

  Status.each do |status|
    define_method("#{status}?") do
      self.status == status
    end
  end

  def need_deposit_invoice?
    return false if self.deposit_invoice_generated?
    return false if self.rate_rule.deposit_out == 0.to_money

    conf = self.confirmation_invoice
    return false unless conf
    conf.items.select{ |i| i.name =~ /Dépot/ }.size > 0
  end

  # TODO rewrite this with a named scope?
  # @note FIXME old, slow, stupid and inapropriate.
  # Use cached values in reservation itself and callbacks when recording  invoices
  def reservation_invoices_generated?(start_date, end_date, explain = false)
    inv = self.reservation_invoices

    # Check we have invoices
    return "No invoice yet" if inv.empty? and explain
    return false if inv.empty?

    start_date = self.arrival if self.arrival > start_date
    end_date = self.departure if self.departure < end_date

    inv = inv.sort_by { |i| [i.interval_start, i.interval_end] }

    # Check we cover all of the interval
    inv.inject(start_date) do |start, i|
      return "Gap between : " + (start - 1.day).to_s + " and " + i.interval_start.to_s if i.interval_start > start and explain
      return false unless i.interval_start <= start
      i.interval_end + 1.day
    end
    return "Gap between : " + inv.last.interval_end.to_s + " and " + (end_date - 1.day).to_s if inv.last.interval_end < end_date and explain
    inv.last.interval_end >= end_date
  end

  def all_reservation_invoices_generated?
    self.reservation_invoices_generated?(self.arrival, self.departure)
  end

  def make_reservation_invoice(start_date, end_date)
    return nil if reservation_invoices_generated?(start_date, end_date)
    invoice = ReservationInvoice.new(reservation: self, interval_start: start_date, interval_end: end_date)
    invoice.compute_items
    invoice
  end

  def total
    # Sum existing invoices
    total = self.invoices.inject(0.to_money) do |sum, invoice|
      sum + invoice.value
    end

    # Add possible confirmation invoice
    if ! self.confirmation_invoice_generated? and ! self.confirmed?
      total += self.make_confirmation_invoice.value
    end

    # Add possible reservation invoices
    inv = self.reservation_invoices.sort_by { |i| [i.interval_start, i.interval_end] }
    if inv.empty?
      total += make_reservation_invoice(self.arrival, self.departure).value
    else
      inv.inject(self.arrival) do |start, i|
        total += make_reservation_invoice(start, i.interval_start - 1.day).value unless i.interval_start <= start
        i.interval_end + 1.day
      end
      total += make_reservation_invoice(inv.last.interval_end + 1.day, self.departure).value if inv.last.interval_end < self.departure
    end

    # Add possible deposit invoice
    total += self.make_deposit_invoice.value unless self.deposit_invoice_generated?

    # Return the computed total
    total
  end

  def due
    self.total - self.paid
  end

  def paid
    self.invoices.all.inject(0.to_money) do |sum, invoice|
      sum + invoice.incomes_total
    end
  end

  def deletable?
    self.invoices.each do |invoice|
      return false unless invoice.incomes.empty?
    end
    true
  end

  def to_s
    "#{resident.full_name}, room #{room} (#{interval_string})"
  end

  private

    def validate_params
      errors.add :resident_full_name, 'must be set' unless self.resident && self.resident.valid?
      errors.add :arrival, 'must be set' unless self.arrival
      errors.add :departure, 'must be set' unless self.departure
      errors.add :room_id, 'must be set' unless self.room.is_a?(Room)

      if self.arrival && self.departure
        errors.add :departure, 'cannot be before or equal to arrival' if self.departure <= self.arrival

        # TODO remove once tested
        # Check there's no overlapping reservations
        # conditions = {}
        # conditions[:id_ne]        = self.id
        # conditions[:room_id]      = self.room_id
        # conditions[:status_ne]    = 'cancelled'
        # conditions[:arrival_lt]   = self.departure
        # conditions[:departure_gt] = self.arrival
        # others = self.class.find_all, conditions: conditions)
        t = self.class.arel_table
        others = self.class
          .where(id: id, room_id: room_id, arrival: departure)
          .where(t[:arrival].lt(departure))
          .where(t[:departure].gt(arrival))
          .where.not(status: 'cancelled')
        errors.add :reservation, "overlaps with another reservation #{others.join(',')}" unless others.empty?
      end
    end

end
