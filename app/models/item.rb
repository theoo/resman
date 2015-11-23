class Item < ActiveRecord::Base
  money :value, currency: false

  belongs_to  :invoice

  validates_presence_of :name

  def validate
    errors.add :value, 'cannot be null' if self.value == 0.to_money
  end

  def git_line
    case self.name
      when /^Room \d+$/
        rule = self.invoice.reservation.rate_rule
        long_period = rule.value_type == 'month'
        account_id = Option.value(long_period ? 'git_room_long' : 'git_room_short')
      when /^Taxe de confirmation$/
        account_id = Option.value('git_tax')
      when /^Dépot/
        account_id = Option.value('git_deposit')
      when /Frigo/
        account_id = Option.value('git_fridge')
      when /rappel/
        account_id = Option.value('git_reminder')
      when /internet/i
        account_id = Option.value('git_internet')
      else
        account_id = Option.value('git_misc')
    end

    make_git_line(date: self.invoice.created_at.strftime('%d.%m.%Y'),
                  voucher_id: self.invoice.id,
                  account_id: account_id,
                  account_ccy: 'CHF',
                  text: self.name,
                  occy_amount: 0,
                  bccy_amount: -self.value)
  end
end