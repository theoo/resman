
tile_size    = 12.8
rooms_offset = 4
dates_offset = 2

days = (@start..@stop).inject({}) do |hash, date|
  desc = date.strftime('%a').downcase
  hash[desc] ||= []
  hash[desc] << date
  hash
end

is = json.array!
# Rooms block
is << { type: 'block',
  rect: [0, dates_offset, rooms_offset, @planning.size],
  color: '#fff' }

# Contents block
is << { type: 'block',
  rect: [rooms_offset, dates_offset, @duration, @planning.size],
  color: '#fff',
  reservable: true }

# Mondays & fridays
(days['mon'] + days['fri']).map do |d|

  is << { type: 'text',
    x: (rooms_offset + (d - @start)).to_i,
    y: 1,
    value: d.day,
    color: '#000' }

end

# Week-ends
(days['sat'] + days['sun']).each do |d|

  is << { type: 'block',
    rect: [(rooms_offset + (d - @start)).to_i, dates_offset, 1, @planning.size],
    color: '#eee',
    reservable: true}

end

# Vertical lines
@duration.times do |i|

  is << { type: 'line',
    x1: rooms_offset + i,
    y1: dates_offset,
    x2: rooms_offset + i,
    y2: dates_offset + @planning.size,
    color: '#ccc' }

end

@planning.each_with_index do |hash, i|

  # Room name
  is << { type: 'text',
    x: 1,
    y: dates_offset + i,
    value: hash[:room].name,
    color: '#000' }

  # Reservations blocks
  hash[:reservations].each do |reservation|

    h = { type: 'block',
      rect: [rooms_offset + days_from_start(reservation, @start),
        dates_offset + i,
        [reservation_length(reservation, @start), @duration].min, 1],
      color: reservation.resident.color,
      reservation_id: reservation.id }

    h[:fade] = true if reservation.status == 'pending'
    is << h

    if params[:show_names]

      is << { type: 'text',
        x: rooms_offset + days_from_start(reservation, @start),
        y: dates_offset + i,
        value: reservation.resident.full_name,
        color: '#000' }

    end
  end
end

# Months

month = @start
while month < @stop do

  is << { type: 'text',
    x: (rooms_offset + (month - @start)).to_i,
    y: 0,
    value: month.strftime('%B'),
    color: '#000' }

  is << { type: 'line',
    x1: (rooms_offset + (month - @start)).to_i,
    y1: 0,
    x2: (rooms_offset + (month - @start)).to_i,
    y2: (dates_offset + @planning.size).to_i,
    color: '#999',
    width: 2 }

  month = month.next_month
end

# Today
is << { type: 'line',
  x1: (rooms_offset + (Date.today - @start)).to_i,
  y1: 0,
  x2: (rooms_offset + (Date.today - @start)).to_i,
  y2: (dates_offset + @planning.size).to_i,
  color: '#f00', width: 1 }

is
