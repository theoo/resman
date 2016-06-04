# TODO make it so we can't create overlapping periods
# TODO remove interval_start? it's unused anyway

class Rule < ActiveRecord::Base

  Types = %w{ day month }

  belongs_to    :rate

  monetize :value_in_cents, currency_column: :value_currency
  monetize :tax_in_in_cents, currency_column: :value_currency
  monetize :tax_out_in_cents, currency_column: :value_currency
  monetize :deposit_in_in_cents, currency_column: :value_currency
  monetize :deposit_out_in_cents, currency_column: :value_currency

  validates_presence_of       :rate_id
  validates_numericality_of   :end_value, allow_nil: true
  validates_numericality_of   :start_value
  validates_inclusion_of      :start_type, :end_type, :value_type, in: Types

  def validate
    errors.add :value, 'must be positive' unless self.value > 0.to_money
    # TODO add checks for tax_in, deposit_in etc?

    # Check there's no overlapping rules
    # self.rate.rules.each do |rule|
    #   next if rule == self
    #   if self.interval_range.overlaps?(rule.interval_range)
    #     errors.add :rule, "overlaps with another rule (#{rule})"
    #     break
    #   end
    # end
  end

  def interval_start
    self.start_value.send(self.start_type)
  end

  def interval_end
    return 1/0.0 unless self.end_value # No value means Infinity
    self.end_value.send(self.end_type)
  end

  def interval_string
    start, stop = self.interval_start.inspect, self.interval_end.inspect
    start = "0 #{self.start_type}" if start.empty?
    "from #{start} to #{stop}"
  end

  def value_string
    # the method below return the value_type in plural, which isn't right
#    self.value.to_s.to_f.send(self.value_type).inspect.gsub(' ', '/')
    self.value.to_s + "/" + self.value_type
  end

  def deposit_string
    "in(#{deposit_in})/out(#{deposit_out})"
  end

  def tax_string
    "in(#{tax_in})/out(#{tax_out})"
  end

  def to_s
    "#{interval_string} (#{value_string})"
  end
end
