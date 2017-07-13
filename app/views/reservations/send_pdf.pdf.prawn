# Use the Variable PDF::Writer::FontMetrics::METRICS_PATH in a console to find the font path
# It's probably necessary for ocrb10 (BVR)
require "prawn/measurement_extensions"

margins = [12.5.mm, 25.mm, 12.5.mm, 12.5.mm]
prawn_document(top_margin: margins[0], left_margin: margins[1], bottom_margin: margins[2], right_margin: margins[3]) do |pdf|

  pdf.font "Helvetica"
  pdf.font_size 20

  pdf.move_down 10.mm

  pdf.text "Reservation #{@reservation.id}"

  pdf.move_down 10.mm

  pdf.font_size 10

  data = [
    [ "Nom", @resident.last_name ],
    [ "Prenom", @resident.first_name ],
    [ "Adresse", @resident.address ],
    [ "Nationalite", @resident.country.try(:name) ],
    [ "Sexe", @resident.translated_gender ],
    [ "Date de naissance", @resident.birthdate.strftime("%d.%m.%Y") ],
    [ "Pièce d'identite", @resident.identity_card ],
    [ "Date d'arrivee", @reservation.arrival.strftime("%d.%m.%Y") ],
    [ "Date de départ annoncee", @reservation.departure.strftime("%d.%m.%Y") ],
    [ "Numero de chambre", @reservation.room.try(:name) ]
  ]

  pdf.table data,
    position: :left,
    row_colors: ['ffffff', 'eeeeee'],
    cell_style: { borders:  [], padding: [5, 2] } do

      column(0).align = :left
      column(0).font_style = :bold
    end

end