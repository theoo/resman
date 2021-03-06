require 'csv'

class InvoicesController < ApplicationController

  def ajax_invoice_closed
    invoice = Invoice.find(params[:invoice_id])
    invoice.closed = (params[:closed] == "true")
    invoice.save!
    render nothing: true
  end

  def index

    @q = Invoice.search(params[:q])
    @invoices = @q.result
      .includes( {reservation: [:room, :resident]}, :items )
      .page(params[:page])

  end

  def show
    @invoice = Invoice.find(params[:id])
    # TODO do a REST /invoices/1.pdf with respond_to do |format|

  end

  def new
    # Get params
    if params[:invoice][:type] == 'ReservationInvoice'
      params[:invoice][:interval_start] = Date.new(params[:date][:from][:year].to_i, params[:date][:from][:month].to_i, 1).beginning_of_month
      params[:invoice][:interval_end] = Date.new(params[:date][:to][:year].to_i, params[:date][:to][:month].to_i, 1).end_of_month
    end

    # Create invoice
    @invoice = Invoice.factory(params[:invoice])

    # Compute items
    @invoice.compute_items

    # Check for errors
    unless @invoice.is_a?(CustomInvoice) || @invoice.valid?
      flash[:error] = @invoice.errors.to_a.join("\n")
      return redirect_to(@invoice.reservation)
    end


  end

  def create
    @invoice = Invoice.factory(params[:invoice])

    if @invoice.save
      flash[:notice] = 'Invoice was successfully created.'
      redirect_to(controller: :invoices, action: :show, id: @invoice.id)
    else
      render action: 'new'
    end
  end

  def confirm
    # Get options
    year, month = params[:date][:year].to_i, params[:date][:month].to_i
    @date_start  = Date.new(year, month, 1)
    @date_end    = @date_start.end_of_month

    # HACK fixme
    if params[:download]

      # TODO remove once tested
      # invoices = Invoice.find_all, conditions: { interval_start_gte: @date_start, interval_end_lte: @date_end,
      # type: 'ReservationInvoice', reservation: { status_ne: 'cancelled' }})
      invoices = Invoice.joins(:reservation)
        .where("? <= invoices.interval_start AND invoices.interval_end <= ?", @date_start, @date_end)
        .where(type: "ReservationInvoice")
        .where.not("reservations.status" => 'cancelled')

      if invoices.empty?
        flash[:notice] = 'Nothing to download for this period'
        return redirect_to(invoices_path)
      end
      return redirect_to(action: :send_pdf, format: :pdf, ids: invoices.map{ |r| r.id })
    end

    # Get the list of reservations to process
    # TODO remove once tested
    # .find_all, conditions: { arrival_lte: @date_end, departure_gt: @date_start,
    # status_ne: 'cancelled' })
    reservations = Reservation
      .where("arrival <= ? AND ? < departure", @date_end, @date_start)
      .where.not(status: 'cancelled')

    # Remove those for which we already have an invoice covering that period
    reservations = reservations.reject do |r|
      r.reservation_invoices_generated?(@date_start, @date_end)
    end

    # Create the list of invoices
    @invoices = reservations.map do |reservation|
      reservation.make_reservation_invoice(@date_start, @date_end)
    end

    # Redirect if we have nothing to generate
    if @invoices.empty?
      flash[:notice] = 'Nothing to generate for this period'
      redirect_to(invoices_path)
    end
  end

  def generate
    # FIXME change it so it accepts an html array of invoices
    # Create invoices
    date_start, date_end = params[:date_start].to_default_date, params[:date_end].to_default_date
    @invoices = params[:reservations].map do |id|
      Reservation.find(id).make_reservation_invoice(date_start, date_end)
    end

    # Save them
    Invoice.transaction do
      @invoices.each do |invoice|
        invoice.save!
      end
    end

    flash[:notice] = 'Invoices were successfully created.'
    redirect_to(invoices_path)
  end

  def export_all
    date_start  = Date.new(params[:date][:from][:year].to_i, params[:date][:from][:month].to_i, params[:date][:from][:day].to_i)
    date_end    = Date.new(params[:date][:to][:year].to_i, params[:date][:to][:month].to_i, params[:date][:to][:day].to_i).to_time.end_of_day

    # TODO Remove comment once tested
    # find_all, conditions: { created_at_gte: date_start, created_at_lte: date_end,
    #   reservation: { status_ne: 'cancelled' }}, order_by: { reservation: { resident: [ :last_name, :first_name] }})
    invoices = Invoice.joins(:reservation, :resident)
      .where("? <= invoices.created_at AND invoices.created_at <= ?", date_start, date_end)
      .where.not("reservations.status" => 'cancelled')
      .order("residents.last_name, residents.first_name")

    invoices = invoices.select{ |i| i.open? } if params[:open]

    if params[:git]
      invoices = invoices.select{ |i| i.is_a?(ReservationInvoice) }
      tab_string = invoices.inject(git_header) do |str, invoice|
        str << invoice.git_lines
      end
      send_data( tab_string, type: 'application/octet-stream', filename: "invoices.txt", disposition: 'attachment')
    else
      csv_string = CSV.generate do |csv|
        csv << ["Invoices from #{date_start.to_s(:formatted)} to #{date_end.to_date.to_s(:formatted)}"]
        csv << []
        csv << %w{id type resident resident_id room created from to value paid remaining}
        invoices.each do |invoice|
          csv << [invoice.id, invoice.type, invoice.resident.full_name, invoice.resident.id, invoice.reservation.room.name, invoice.created_at.to_date.to_s(:formatted), invoice.interval_start.to_date.to_s(:formatted), invoice.interval_end.to_date.to_s(:formatted), invoice.value, invoice.incomes_total, invoice.remaining]
        end
        csv << []
        csv << [nil, nil, nil, nil, nil, nil, nil,
          'Total',
          invoices.map(&:value).sum,
          invoices.map(&:incomes_total).sum,
          invoices.map(&:remaining).sum]
      end
      send_data(csv_string,
        type: "text/csv",
        filename: "invoices.csv",
        disposition: 'attachment')
    end
  end

  def send_pdf
    @invoices = Invoice.find(params[:ids])
    @bvr = params[:bvr] || true
    # @rails_pdf_inline = true
    # @paper = 'A4'
    # @rails_pdf_name = "#{@invoices.first.interval_start.to_time.strftime('%Y_%m')}_invoices.pdf"
    render layout: false
  end

  # RailsPdf: Scott Wilson suggested adding the following two block so errors will always show in browser
  def rescue_action_in_public(exception)
    headers.delete("Content-Disposition")
    super
  end

  def rescue_action_locally(exception)
    headers.delete("Content-Disposition")
    super
  end

  private

    def git_header
      "Date\tVoucher\tG/L Account\tG/L Account Ccy\tClient Account\tClient Ccy\tInvoice\tAnalysis Account\tAnalysis Ccy\tText1\tOriginal Amount\tBook Keeping Amount\tText 2\tInvoice type\tCode tva\tCode Jnl\tSTOP PMT 0 OU 1\tRAISON STOP\tTEXTE1 INV\tTEXTE2 INV\r\n"
    end

end
