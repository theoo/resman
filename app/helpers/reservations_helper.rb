module ReservationsHelper
  def js_date(date)
    "new Date('#{date.strftime('%B %d, %Y')}')"
  end

  def js_str(str)
    "'#{str.gsub('\'', '\\\\\'')}'"
  end

  def reservation_length(reservation, start)
    return reservation.departure - reservation.arrival if reservation.arrival > start
    reservation.departure - start
  end

  def days_from_start(reservation, start)
    return 0 if start > reservation.arrival
    reservation.arrival - start
  end

  def items_string
    days = (@start..@stop).inject({}) do |hash, date|
      desc = date.strftime('%a').downcase
      hash[desc] ||= []
      hash[desc] << date
      hash
    end

    is = ""
    # Rooms block
    is << "{ type: 'block', rect: [0, dates_offset, rooms_offset, #{@planning.size}], color: '#fff' },"

    # Contents block
    is << "{ type: 'block', rect: [rooms_offset, dates_offset, #{@duration}, #{@planning.size}], color: '#fff', reservable: true },"

    # Mondays & fridays
    (days['mon'] + days['fri']).each do |d|
      is << "{ type: 'text', x: rooms_offset + #{d - @start}, y: 1, value: #{d.day}, color: '#000' },"
    end

    # Week-ends
    (days['sat'] + days['sun']).each do |d|
      is << "{ type: 'block', rect: [rooms_offset + #{d - @start}, dates_offset, 1, #{@planning.size}], color: '#eee', reservable: true},"
    end

    # Vertical lines
    @duration.times do |i|
      is << "{ type: 'line', x1: rooms_offset + #{i}, y1: dates_offset, x2: rooms_offset + #{i}, y2: dates_offset + #{@planning.size}, color: '#ccc' },"
    end

    @planning.each_with_index do |hash, i|
      # Room name
      is << "{ type: 'text', x: 1, y: dates_offset + #{i}, value: #{js_str(hash[:room].name)}, color: '#000' },"
      # Reservations blocks
      hash[:reservations].each do |reservation|
        is << "{ type: 'block', rect: [rooms_offset + #{days_from_start(reservation, @start)}, dates_offset + #{i}, #{[reservation_length(reservation, @start), @duration].min}, 1], color: #{js_str("##{reservation.resident.color}")}, reservation_id: #{reservation.id}, #{'fade: true' if reservation.status == 'pending'} },"
        if params[:show_names]
          is << "{ type: 'text', x: rooms_offset + #{days_from_start(reservation, @start)}, y: dates_offset + #{i}, value: #{js_str(reservation.resident.full_name)}, color: '#000' },"
        end
      end
    end

    # Months
    (@start..@stop).step(1.month) do |d|
      is << "{ type: 'text', x: rooms_offset + #{d - @start}, y: 0, value: #{js_str(d.strftime('%B'))}, color: '#000' },"
      is << "{ type: 'line', x1: rooms_offset + #{d - @start}, y1: 0, x2: rooms_offset + #{d - @start}, y2: dates_offset + #{@planning.size}, color: '#999', width: 2 },"
    end

    # Today
    is << "{ type: 'line', x1: rooms_offset + #{Date.today - @start}, y1: 0, x2: rooms_offset + #{Date.today - @start}, y2: dates_offset + #{@planning.size}, color: '#f00', width: 1 },"

    is
  end
end
