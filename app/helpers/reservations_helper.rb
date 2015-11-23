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
end
