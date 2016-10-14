module GitConcern

  extend ActiveSupport::Concern

  def make_git_line(hash)
    str   = ''
    delim = "\t"
    eol   = "\r\n"

    #%w{ voucher_id account_id client_id invoice_id }.each do |s|
    %w{ invoice_id }.each do |s|
      hash[s.to_sym] = hash[s.to_sym].to_s.rjust(6, '0') if hash[s.to_sym]
    end

    str << "#{hash[:date]}#{delim}"             # Date
    str << "#{hash[:voucher_id]}#{delim}"       # Voucher (invoice id)
    str << "#{hash[:account_id]}#{delim}"       # GLAccount
    str << "#{hash[:account_ccy]}#{delim}"      # GLccy
    str << "#{hash[:client_id]}#{delim}"        # Client account (resident id)
    str << "#{hash[:client_ccy]}#{delim}"       # Client account ccy
    str << "#{hash[:invoice_id]}#{delim}"       # Invoice number (invoice id)
    str << delim                                # Analytical account
    str << delim                                # Analytical account ccy
    str << "#{hash[:text][0..29]}#{delim}"      # Text line 1 (30 chars max)
    str << "#{hash[:occy_amount]}#{delim}"      # Occy amount
    str << "#{hash[:bccy_amount]}#{delim}"      # Bccy amount
    str << delim                                # Text line 2 (30 chars max)
    str << "#{hash[:invoice_type]}#{delim}"     # Invoice type
    str << delim                                # Tax code
    str << delim                                # Journal code
    str << delim                                # Invoice stop payment flag
    str << delim                                # Invoice stop payment text
    str << delim                                # Invoice text 1
    str << eol                                  # Invoice text 2
  end

end
