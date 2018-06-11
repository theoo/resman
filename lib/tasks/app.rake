require 'csv'

def colorize(text, color_code)
  "#{color_code}#{text}\e[0m"
end

def red(text); colorize(text, "\e[31m"); end
def green(text); colorize(text, "\e[32m"); end
def yellow(text); colorize(text, "\e[33m"); end

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

    SYNC_URI = "https://www.cstb.ch/csv-download/"

    params = {
      key: ENV["CSTB_CH_API_KEY"],
      max_item: -1, # -1 = all
      offset: 0,
      mark_sync: true,
      get_sync_only: true,
      delete_sync_mark: false,
      only_accepted: true
    }

#    params = {
#      key: ENV["CSTB_CH_API_KEY"],
#      max_item: -1, # -1 = all
#      offset: 0,
#      mark_sync: true,
#      get_sync_only: true,
#      delete_sync_mark: false,
#      only_accepted: true
#    }

    response = RestClient.get SYNC_URI, params: params

    columns_list = %i(id date room last_name first_name address email phone project_description start_date end_date price gender
      civil national birth_date passport_number establisment max_budget entrance_date education revenues sport_description source
      motivations formslug filetype profile_image_uri application_pdf_uri)
    csvStruct = Struct.send(:new, *columns_list)

    # blob = File.open(Rails.root.to_s + "/export.csv").read.encode(universal_newline: true)

    blob = response.body.encode(universal_newline: true)

    CSV.parse(blob, encoding: 'UTF-8', quote_char: '"', col_sep: ",").each_with_index do |row, row_index|
      line = csvStruct.new(*row)
      next if line.id.nil? or line.id == "ID"
      begin
        Integer(line.id)
      rescue
        next
      end

      begin
        birth_date = Date.new(*line.birth_date.split("/").reverse.map(&:to_i)) if line.birth_date
        raise ArgumentError, "Invalid date" if birth_date.year < 1900 or birth_date.year > Time.now.year
      rescue
        birth_date = nil
        puts red("Invalid date #{line.birth_date} for next entry.")
      end

      if resident = Resident.where(first_name: line.first_name, last_name: line.last_name).first

        puts red("Resident #{resident.full_name} already in database.")

      else

        resident = Resident.create(
          country: Country.where(name: line.national).first,
          school: School.where(name: line.establisment).first,
          color: "FF0000",
          first_name: line.first_name,
          last_name: line.last_name,
          address: line.address,
          email: line.email,
          phone: line.phone,
          identity_card: line.passport_number
        )

        resident.gender = (line.gender.match(/M\.|Mr\./) ? "man" : "woman") if line.gender
        resident.birthdate = birth_date if birth_date
        resident.tag_list << "Import"

        resident.save!

        if line.profile_image_uri

          begin
            response = RestClient.get line.profile_image_uri
          rescue => e
            puts red("#{e.inspect}")
          end

          if response and response.code == 200
            file = Tempfile.new(["profile_image", ".png"])
            file.binmode
            file.write response.body
            resident.update_attributes profile_picture: file
            file.unlink
            puts green("Profile picture imported.")
          else
            puts red("Unable to import Profile picture.")
          end
        end

        if line.application_pdf_uri

          begin
            response = RestClient.get line.application_pdf_uri
          rescue => e
            puts red("#{e.inspect}")
          end

          if response and response.code == 200
            file = Tempfile.new(["application", ".pdf"])
            file.binmode
            file.write response.body
            profile = resident.attachments.create(title: "application_pdf", file: file)
            file.unlink
            puts green("Application PDF imported in attachments.")
          else
            puts red("Unable to import Application PDF.")
          end
        end

        puts green("Resident #{resident.full_name} created.")

      end


    end

  end

end
