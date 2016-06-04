require 'csv'

class ResidentsController < ApplicationController

  def autocomplete_name
    name = params[:term]
    @residents = Resident.where("first_name REGEXP ? OR last_name REGEXP ?", name, name)
      .order(:last_name, :first_name)
    respond_to do |wants|
      wants.json { }
    end
  end

  def index
    params[:q] ||= { tags_name_eq: Option.value('residents_listing_selected_tag') }
    # raise ArgumentError, params.inspect
    @q = Resident.search(params[:q])
    @residents = @q.result.includes([:country, :religion, :school]).page(params[:page])
  end

  def show
    @resident = Resident.find(params[:id])

  end

  def new
    @resident = Resident.new

  end

  def edit
    @resident = Resident.find(params[:id])

  end

  def create
    @resident = Resident.new(params[:resident])
    if @resident.save
      flash[:notice] = 'Resident was successfully created.'
      redirect_to(@resident)
    else
      render action: 'new'
    end
  end

  def update
    @resident = Resident.find(params[:id])
    if @resident.update_attributes(params[:resident])
      flash[:notice] = 'Resident was successfully updated.'
      redirect_to(@resident)
    else
      render action: 'edit'
    end
  end

  def destroy
    @resident = Resident.find(params[:id])
    raise 'Asked to delete something not deletable (how?)' unless @resident.deletable?
    Resident.transaction { @resident.destroy }
    redirect_to(residents_url)
  end

  def export
    date_start  = Date.new(params[:date][:from][:year].to_i, params[:date][:from][:month].to_i, 1).beginning_of_month
    date_end    = Date.new(params[:date][:to][:year].to_i, params[:date][:to][:month].to_i, 1).to_time.end_of_month

    resident = Resident.find(params[:id])
    # TODO remove once tested
    # find_all, conditions: { created_at_gte: date_start, created_at_lte: date_end })
    invoices = resident.invoices
      .where("? <= created_at AND created_at <= ?", date_start, date_end)

    csv_string = CSV.generate do |csv|
      csv << ["Invoices for #{resident.full_name} (id: #{resident.id}) from #{date_start.to_s(:formatted)} to #{date_end.to_s(:formatted)}"]
      csv << []
      csv << %w{id type created/received value}
      invoices.each do |invoice|
        csv << [invoice.id, invoice.type, invoice.created_at.to_date.to_s(:formatted), -invoice.value]
        invoice.incomes.each do |income|
          csv << [income.id, "Income #{income.payment}", income.received.to_s(:formatted), income.value]
        end
      end
    end

    send_data(csv_string,
      type: 'text/csv',
      filename: "resident_#{resident.id}.csv",
      disposition: 'attachment')
  end

  def export_all
    year, month, day = params[:date][:year].to_i, params[:date][:month].to_i, params[:date][:day].to_i
    date = Date.new(year, month, day)
    residents = Resident.all.order([:last_name, :first_name])

    csv_string = CSV.generate do |csv|
      csv << ["Residents occupation the #{date.to_s(:formatted)}"]
      csv << []
      csv << %w{id arrival_date room last_name first_name birth_date gender country school address identity_card departure_date email religion tags }
      residents.each do |r|
        r.reservations_at(date).each do |current_reservation|
          next if current_reservation.status == 'cancelled'
          csv << [r.id, current_reservation.arrival_formatted, current_reservation.room, r.last_name, r.first_name, r.birthdate_formatted, r.gender, r.country, r.school, r.address, r.identity_card, current_reservation.departure_formatted, r.email, r.religion, r.tag_list.join(', ')]
        end
      end
    end

    send_data(csv_string,
      type: 'text/csv',
      filename: date.strftime('residents_%d_%m_%y.csv'),
      disposition: 'attachment')
  end

end
