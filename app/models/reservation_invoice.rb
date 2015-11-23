class ReservationInvoice < Invoice

  def compute_items
    # Adjust interval_start to fit reservation if needed
    self.interval_start = self.reservation.arrival if self.interval_start < self.reservation.arrival
    self.interval_end = self.reservation.departure if self.interval_end > self.reservation.departure

    # Add room's price
    self.items.build(name: "Room #{self.reservation.room}", value: self.reservation.room_price(self.interval_start, self.interval_end))

    # For the first reservation invoice
    unless self.reservation.invoices.find_by_type(self.class.to_s)
      # Give tax back
      rule = self.reservation.rate_rule
      unless rule.tax_out == 0.to_money
        # Take the value credited if there is one, otherwise rule's value
        value = rule.tax_out
        conf = self.reservation.confirmation_invoices.first
        if conf
          item = conf.items.select{ |i| i.name =~ /confirmation/ }.first
          if item
            value = (conf.incomes_total > 0.to_money) ? conf.incomes_total : item.value
          end
          self.items.build(name: 'Taxe de confirmation', value: -value)
        end
      end

      # Add unique reservations options
      self.reservation.options.find_all_by_billing('unique').each do |option|
        self.items.build(name: option.name, value: option.value)
      end
    end

    # Add mensual reservations options
    self.reservation.options.find_all_by_billing('mensual').each do |option|
      months = self.reservation.months_in_common_with(self.interval_start, self.interval_end)
      self.items.build(name: "#{option.name} (#{months} months)", value: option.value * months)
    end
  end
end