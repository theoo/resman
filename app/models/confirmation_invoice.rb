class ConfirmationInvoice < Invoice
  def compute_items
    # Get rule
    rule = self.reservation.rate_rule

    # Build items
    self.items.build(name: 'Taxe de confirmation', value: rule.tax_in) unless rule.tax_in == 0.to_money
    self.items.build(name: 'Dépot de garantie', value: rule.deposit_in) unless rule.deposit_in == 0.to_money
  end
end