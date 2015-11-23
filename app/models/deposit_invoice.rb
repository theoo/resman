class DepositInvoice < Invoice
  def compute_items
    # Get rule
    rule = self.reservation.rate_rule

    # Check if we aren't in a special "reservation resized" case
    value = rule.deposit_out
    if value == 0.to_money
      conf = self.reservation.confirmation_invoice
      return unless conf
      item = conf.items.select{ |i| i.name =~ /Dépot/ }.first
      return unless item
      value = item.value
    end

    # Build deposit item
    self.items.build(name: 'Dépot de garantie', value: -value)
  end
end
