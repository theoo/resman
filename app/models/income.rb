class Income < ActiveRecord::Base

  extend  MoneyComposer

  Types = %w{ bvr bank cash credit_note accounting_correction }

  belongs_to    :invoice

  has_many :comments,
    as: :entity,
    dependent: :destroy

  money :value, currency: false

  formatted_date :received
  log_after :update, :destroy

  after_create :after_create_method

  def self.parse_bank_file(data)
    incomes = []
    already_parsed = []
    unparsed = []
    data.split(/[\r\n ]+/).each do |line|
      hash = self.parse_bank_file_line(line)
      if hash
        invoice = Invoice.exists?(hash[:invoice_id]) ? Invoice.find(hash[:invoice_id]) : nil
        if invoice.nil? || hash[:invoice_date] != invoice.created_at.to_date || hash[:resident_id] != invoice.resident.id
          unparsed << line
        else
          conditions = { invoice_id: hash[:invoice_id],
              value_in_cents: hash[:value_in_cents],
              received: hash[:date_value] }
          found = Income.where(conditions).first
          if found
            already_parsed << found
          else
            incomes << Income.new(conditions)
          end
        end
      else
        unparsed << line
      end
    end
    return incomes, already_parsed, unparsed
  end

  def self.parse_bank_file_line(line)
    # 012010473005 000070 09012009 1054 000232 02 7 0000074000 0112763772 090110 090112 090113 00001000510000000000175
    # ? - bank - Date facture - client - 000 - réservation - 02 - Modulo - Montant en centimes - ? - Date entrée - Date écriture - Date valeur - ?
    matches = line.match(/^\d{12}(\d{6})(\d{8})(\d{4})(\d{6})0[02](\d)(\d{10})\d{10}(\d{6})(\d{6})(\d{6})\d{23}$/)
    return nil unless matches

    # We need this little hack because production uses Ruby 1.8.5 and Date#strptime is bugged there
    fix_date_string = proc do |str|
      str.insert(4, '.')
      str.insert(2, '.')
      str
    end

    hash = {}
    hash[:bank_bvr_number]  = matches.captures[0].to_i
    hash[:invoice_date]     = Date.strptime(fix_date_string.call(matches.captures[1]), '%d.%m.%Y') rescue nil
    hash[:resident_id]      = matches.captures[2].to_i
    hash[:invoice_id]       = matches.captures[3].to_i
    hash[:modulo]           = matches.captures[4].to_i
    hash[:value_in_cents]   = matches.captures[5].to_i
    hash[:date_entry]       = Date.strptime(fix_date_string.call(matches.captures[6]), '%y.%m.%d') rescue nil
    hash[:date_write]       = Date.strptime(fix_date_string.call(matches.captures[7]), '%y.%m.%d') rescue nil
    hash[:date_value]       = Date.strptime(fix_date_string.call(matches.captures[8]), '%y.%m.%d') rescue nil
    hash
  end

  def self.options_for_select(hash = {})
    raise NotImplementedError
    arr = all.order(:name).map { |i| ["#{i.interval_string}", i.id] }
    arr.unshift([hash[:text] || 'All', nil]) if hash[:allow_nil]
    arr
  end

  def validate
    errors.add :value, 'cannot be 0' if self.value == 0.to_money
  end

  def save_and_handle_parent
    return false unless self.valid?
    return self.save unless self.value > 0.to_money && self.invoice.parent && self.invoice.parent.due > 0.to_money

    left_over = self.value - self.invoice.parent.due
    parent_value = (left_over > 0.to_money) ? self.invoice.parent.due : self.value
    Income.create!(invoice: self.invoice.parent, value: parent_value, received: self.received, payment: self.payment)
    self.value = left_over
    (self.value > 0.to_money) ? self.save : true
  end

  def after_create_method
    log_activity('create')

    if self.invoice.incomes_total >= self.invoice.value
      self.invoice.closed = true
      self.invoice.save!
    end

    if self.invoice.is_a?(ConfirmationInvoice) && self.invoice.closed? && self.invoice.reservation.status == 'pending'
      self.invoice.reservation.status = 'confirmed'
      self.invoice.reservation.save!
    end
  end

  def reservation
    self.invoice.reservation
  end

  def resident
    self.invoice.resident
  end

  def room
    self.invoice.room
  end

  def to_s
    "#{invoice}, value: #{value}"
  end
end
