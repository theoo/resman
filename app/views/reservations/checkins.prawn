# Use the Variable PDF::Writer::FontMetrics::METRICS_PATH in a console to find the font path
# It's probably necessary for ocrb10 (BVR)
require "prawn/measurement_extensions"

margins = [12.5.mm, 25.mm, 12.5.mm, 12.5.mm]
prawn_document(top_margin: margins[0], left_margin: margins[1], bottom_margin: margins[2], right_margin: margins[3]) do |pdf|

  pdf.font "Helvetica"
  pdf.font_size 20

  pdf.text "Check-in du #{Date.today.strftime("%d.%m.%Y")}"

  pdf.font_size 10

  @reservations.each do |reservation|

    resident = reservation.resident

    pdf.move_down 10.mm

    data = [
      [ "Nom", resident.last_name ],
      [ "Prénom", resident.first_name ],
      [ "Adresse", resident.address ],
      [ "Nationalité", resident.country.try(:name) ],
      [ "Sexe", resident.translated_gender ],
      [ "Date de naissance", resident.birthdate.strftime("%d.%m.%Y") ],
      [ "Pièce d'identité", resident.identity_card ],
      [ "Date d'arrivée", reservation.arrival.strftime("%d.%m.%Y") ],
      [ "Date de départ annoncée", reservation.departure.strftime("%d.%m.%Y") ],
      [ "Numéro de chambre", reservation.room.try(:name) ],
      [ "Reservation n°", reservation.id]
    ]

    pdf.table data,
      position: :left,
      row_colors: ['ffffff', 'eeeeee'],
      cell_style: { borders:  [], padding: [5, 2] } do

        column(0).align = :left
        column(0).font_style = :bold
      end

  end

end