require 'csv'

namespace :app do
  desc 'Automatically drops unconfirmed reservations'
  task(delete_unconfirmed_reservations: :environment) do
    User.current_user = User.find(:first, conditions: { login: 'admin' })

    conditions = {}
    conditions[:status] = 'pending'
    conditions[:invoices] = {}
    conditions[:invoices][:type] = 'ConfirmationInvoice'
    conditions[:invoices][:created_at_lt] = Time.now - Option.value('delay_before_cancellation').to_i.day
    Reservation.find(:all, conditions: conditions).each do |reservation|
      if reservation.deletable?
        reservation.destroy
      else
        reservation.status = 'cancelled'
        reservation.save!
      end
    end
  end

  desc 'Sync pending applications (from cstb.ch)'
  task(sync_pending_applications: :environment) do

    SYNC_URI = "http://www.cstb.ch/csv-download/"

    params = {
      key: ENV["CSTB_CH_API_KEY"]
    }

    response = RestClient.get SYNC_URI, params: params

    columns_list = %i(id date room last_name first_name address email phone project_description start_date end_date price gender
      civil national birth_date passport_number establisment max_budget entrance_date education revenues sport_description source
      motivations formslug filetype profile_image_uri application_pdf_uri)
    csvStruct = Struct.send(:new, *columns_list)

    CSV.parse(response.body, encoding: 'UTF-8', quote_char: '"', row_sep: "\r\n", col_sep: ",").each_with_index do |row, row_index|
      applic = csvStruct.new(*row)
      next if applic.id.nil? or applic.id == "ID"
      puts applic.inspect
    end

  end

end
