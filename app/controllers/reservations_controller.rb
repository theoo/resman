class ReservationsController < ApplicationController

  def auto_complete_for_reservation_resident_full_name
    name = params[:reservation][:resident_full_name]
    @residents = Resident.find(:all, conditions: { or_last_name_sw: name, or_first_name_sw: name }, order_by: [:last_name, :first_name])
    render inline: "<%= content_tag(:ul, @residents.map { |r| content_tag(:li, h(r)) }) -%>"
  end

  def index

    if params[:date]
      @from = Date.new(params[:date][:from][:year].to_i, params[:date][:from][:month].to_i, 1)
      @to   = Date.new(params[:date][:to][:year].to_i, params[:date][:to][:month].to_i, 1).end_of_month
    else
      @from = Date.today
      @to   = Date.today
    end

    @to = @from if @to < @from

    @q = Reservation.joins(:resident, :room)
      .where("arrival < ? AND departure > ?", @to, @from)
      .search(params[:q])
    @reservations = @q.result.page(params[:page])
  end

  def planning
    @duration = 90

    @start = params[:start_date] ? params[:start_date].to_default_date : Date.today
    @start = @start.beginning_of_month
    @stop  = @start + @duration.day

    @planning = Room.order(:name).inject([]) do |arr, room|
      arr << {room: room, reservations: room.reservations.where("status != 'cancelled' AND arrival < ? AND departure > ?", @stop, @start).order(:arrival)}
    end
  end

  def show
    @reservation = Reservation.find(params[:id])
  end

  def new
    room = Room.find_by_name(params[:room])
    @reservation = Reservation.new(arrival_formatted: params[:arrival], departure_formatted: params[:departure], room: room, resident_id: params[:resident])
  end

  def ajax_room_options
    @arrival = params[:arrival].to_default_date unless params[:arrival].empty?
    @departure = params[:departure].to_default_date unless params[:departure].empty?
    @room = params[:reservation][:room_id].to_i != 0 ? Room.find(params[:reservation][:room_id]) : nil
    @reservation = params[:reservation_id] ? Reservation.find(params[:reservation_id]) : Reservation.new
    @reservation.room = @room
    @reservation.arrival = @arrival
    @reservation.departure = @departure
    render layout: false
  end

  def ajax_room_availables
    @arrival, @departure = params[:arrival].to_default_date, params[:departure].to_default_date
    reservation_room = params[:reservation_id].to_i != 0 ? Reservation.find(params[:reservation_id]).room : nil
    @selected_room_id = params[:selected_room_id]
    @available_rooms = Room.available_rooms(@arrival, @departure, reservation_room)
    puts @available_rooms.inspect
    puts params.inspect
    render layout: false
  end

  def create
    @reservation = Reservation.new(params[:reservation])
    if @reservation.save
      flash[:notice] = 'Reservation was successfully created.'
      redirect_to(@reservation)
    else
      render action: 'new'
    end
  end

  def edit
    @reservation = Reservation.find(params[:id])

  end

  def update
    # FIXME next line is because of Reservation#options_attributes= ugliness
    params[:reservation][:options_attributes] ||= []

    @reservation = Reservation.find(params[:id])
    if @reservation.update_attributes(params[:reservation])
      flash[:notice] = 'Reservation was successfully updated.'
      redirect_to(@reservation)
    else
      render action: "edit"
    end
  end

  def destroy
    @reservation = Reservation.find(params[:id])
    if @reservation.deletable?
      Reservation.transaction { @reservation.destroy }
      redirect_to(reservations_url)
    else
      @reservation.status = 'cancelled'
      @reservation.save!
      redirect_to(@reservation)
    end
  end
end
