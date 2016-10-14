class Invoice < ActiveRecord::Base

  include GitConcern

  belongs_to    :reservation

  has_many      :items,
    dependent: :destroy

  has_many      :incomes,
    dependent: :destroy

  has_many      :comments,
    as: :entity,
    dependent: :destroy

  has_one :resident, through: :reservation
  has_many :tags, through: :resident

  acts_as_tree

  validates_presence_of :reservation_id

  formatted_date :interval_start, :interval_end, :created_at

  log_after :create, :update, :destroy

  def self.factory(params)
    raise 'Cannot create if we do not know the type' unless params[:type]
    params[:type].constantize.new(params)
  end

  def validate
    # Check dates
    errors.add :interval_start, 'must be set' unless self.interval_start
    errors.add :interval_end, 'must be set' unless self.interval_end
    errors.add :interval_start, 'cannot be after interval end' if self.interval_start > self.interval_end

    # Check we have something to bill
    errors.add :invoice, 'must contains something to bill' if self.items.empty?
  end

  def self.options_for_select(hash = {})
    raise NotImplementedError
    arr = all.order(:name).map { |i| [i.name, i.id] }
    arr.unshift([hash[:text] || 'All', nil]) if hash[:allow_nil]
    arr
  end

  def bvr_ref
    ref  = Option.value('bank_bvr_number').rjust(6, '0')    # 000070
    ref += Time.now.strftime("%d%m%Y").rjust(8, '0')        # Today's date
    ref += self.reservation.resident.id.to_s.rjust(4, '0')  # Resident id
    ref += self.id.to_s.rjust(6, '0')                       # Invoice id
    ref += '02'                                             # Convention?
    ref += ref.to_i.mod10rec.to_s                           # Hum?

    raise 'bvr_ref error' unless ref.size == 27
    ref
  end

  def has_interval?
    self.interval_start && self.interval_end
  end

  def interval_string
    self.interval_start ? "#{self.interval_start_formatted} - #{self.interval_end_formatted}" : 'None'
  end

  def resident
    self.reservation.resident
  end

  def room
    self.reservation.room
  end

  def open?
    !self.closed?
  end

  def paid?
    self.closed?
  end

  def can_be_paid_until?(date)
    self.created_at.to_date + Option.value('invoice_late_delay').to_i.day > date
  end

  def overpaid?
    self.incomes_total > self.value
  end

  def overpaid_value
    self.incomes_total - self.value
  end

  def remaining
    v = self.value - self.incomes_total
    (v > 0.to_money) ? v : 0.to_money
  end

  alias_method :due, :remaining

  def value
    self.items.inject(0.to_money) do |sum, item|
      sum + item.value
    end
  end

  def pdf_value
    self.parent ? self.parent.value + self.value : self.value
  end

  def pdf_items
    self.parent ? self.parent.items + self.items : self.items
  end

  def items_attributes=(items_attributes)
    items_attributes.each do |item_attributes|
      next if item_attributes[:name].empty? && item_attributes[:value].empty?
      self.items.build(item_attributes)
    end
  end

  def compute_items
  end

  def incomes_total
    Money.new(self.incomes.sum(:value_in_cents))
  end

  def to_s
    "#{self.reservation} #{self.interval_string} (#{self.value})"
  end

  def print_name
    "#{self.id}_#{self.created_at.strftime("%m-%d-%Y")}"
  end

  def git_lines
    str = make_git_line(date: self.created_at.strftime('%d.%m.%Y'),
                        voucher_id: self.id,
                        account_id: Option.value('git_debtor'),
                        account_ccy: 'CHF',
                        client_id: self.resident.id,
                        client_ccy: 'CHF',
                        invoice_id: self.id,
                        text: self.interval_start ? "Facture #{self.interval_start_formatted}-#{self.interval_end_formatted}" : 'Facture',
                        occy_amount: 0,
                        bccy_amount: self.value,
                        invoice_type: 'FACC')

    self.items.inject(str) do |s, item|
      s << item.git_line
    end
  end
end