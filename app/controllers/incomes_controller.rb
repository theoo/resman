class IncomesController < ApplicationController
  def index
    @search = Income.new_search(params[:search])
    @search.include = [{invoice: [:items, {reservation: [:room, :resident]}]}]
    @incomes, @incomes_count = @search.all, @search.count
    
  end

  def new
    @invoice = Invoice.find(params[:invoice_id])
    value = @invoice.value - @invoice.incomes_total
    value += @invoice.parent.value - @invoice.parent.incomes_total if @invoice.parent
    @income = Income.new(invoice: @invoice, value: value, received: Date.today)
    
  end

  def create
    @income = Income.new(params[:income])

    if @income.save_and_handle_parent
      flash[:notice] = 'Income was successfully created.'
      redirect_to(controller: :invoices, action: :show, id: @income.invoice)
    else
      render action: 'new'
    end
  end

  def show
    @income = Income.find(params[:id])
    
  end
    
  def confirm
    @incomes, @already_parsed, @unparsed = Income.parse_bank_file(params[:file].read)
    @incomes = @incomes.sort_by{ |i| i.resident.full_name }

    if params[:commit] == 'Upload'
      
    else
      csv_string = FasterCSV.generate do |csv|
        csv << ["Incomes imported from #{params[:file].original_filename}"]
        csv << []
        csv << %w{id invoice_id resident_id resident room payment received value}
        @already_parsed.each do |income|
          csv << [income.id, income.invoice.id, income.resident.id, income.resident.full_name, income.reservation.room.name, income.payment, income.received.to_s(:formatted), income.value]
        end
        csv << []
        csv << [nil, nil, nil, nil, nil, nil, 'Total', @already_parsed.sum(&:value)]
      end
      send_data(Iconv.conv('ISO-8859-1', 'UTF-8', csv_string), type: "text/csv", filename: "incomes.csv", disposition: 'attachment')
    end
  end
  
  def generate
    if params[:incomes]
      incomes = params[:incomes].select{ |hash| hash[:selected] }
      incomes.each do |hash|
        hash.delete('selected')
        hash[:payment] = 'bank'
        Income.new(hash).save_and_handle_parent
      end
      flash[:notice] = 'Incomes imported'
    else
      flash[:notice] = 'Nothing was imported'
    end
    redirect_to incomes_path
  end
  
  def export_all
    date_start  = Date.new(params[:date][:from][:year].to_i, params[:date][:from][:month].to_i, 1).beginning_of_month
    date_end    = Date.new(params[:date][:to][:year].to_i, params[:date][:to][:month].to_i, 1).to_time.end_of_month

    incomes = Income.find(:all, conditions: { received_gte: date_start, received_lte: date_end }, order_by: { invoice: { reservation: { resident: [ :last_name, :first_name] }}})
    
    csv_string = FasterCSV.generate do |csv|
      csv << ["Incomes from #{date_start.to_s(:formatted)} to #{date_end.to_date.to_s(:formatted)}"]
      csv << []
      csv << %w{invoice_id resident_id resident payment received value}
      incomes.each do |income|
        csv << [income.invoice.id, income.resident.id, income.resident.full_name, income.payment, income.received.to_s(:formatted), income.value]
      end
      csv << []
      csv << [nil, nil, nil, nil, 'Total', incomes.sum(&:value)]
    end

    send_data(Iconv.conv('ISO-8859-1', 'UTF-8', csv_string), type: "text/csv", filename: "incomes.csv", disposition: 'attachment')
  end
end
