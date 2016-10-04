# Use the Variable PDF::Writer::FontMetrics::METRICS_PATH in a console to find the font path
# It's probably necessary for ocrb10 (BVR)
require "prawn/measurement_extensions"

margins = [12.5.mm, 25.mm, 12.5.mm, 12.5.mm]
prawn_document(top_margin: margins[0], left_margin: margins[1], bottom_margin: margins[2], right_margin: margins[3]) do |pdf|

  @invoices.each_with_index do |invoice, i|

    pdf.start_new_page unless i == 0

    pdf.font "Helvetica"
    pdf.font_size 10

    #pdf.image "public/images/cstb.jpg", :justification => :center

    ############################################################################################
    # ALL Variables Fields in PDF
    ############################################################################################

    dateINFO = Hash.new
    dateINFO[:now]        = invoice.created_at.strftime('%d.%m.%Y')

    clientINFO = Hash.new
    clientINFO[:id]       = invoice.resident.id.to_s
    clientINFO[:room]     = invoice.room.name
    clientINFO[:company]  = ""
    clientINFO[:titre]    = ""
    clientINFO[:name]     = invoice.resident.full_name
    clientINFO[:address]  = "Av. du Mail 14"
    clientINFO[:locality] = "1205 Geneve"

    invoiceINFO = Hash.new
    invoiceINFO[:id]      = invoice.id.to_s
    invoiceINFO[:debut]   = invoice.interval_start_formatted
    invoiceINFO[:fin]     = invoice.interval_end_formatted

    monneyINFO = Hash.new
    monneyINFO[:francs]   = invoice.pdf_value.to_s.split('.')[0]
    monneyINFO[:cents]    = invoice.pdf_value.to_s.split('.')[1]
    monneyINFO[:ref]      = invoice.bvr_ref
    monneyINFO[:modulo]   = "01" + zerofill(monneyINFO[:francs] + monneyINFO[:cents], 10) \
      + zerofill(monneyINFO[:francs] + monneyINFO[:cents], 10).to_i.mod10rec.to_s + ">" \
      + monneyINFO[:ref] + "+ " + "010473005>"

    #######################################
    # Invoice content
    #######################################

    # Date
    pdf.bounding_box([ 100.mm, 237.5.mm], width: 70.mm, height: 12) do
      # pdf.stroke_bounds
      pdf.text "Geneve, le " + dateINFO[:now], size: 12
    end

    # Address
    pdf.bounding_box([ 100.mm, 225.5.mm], width: 70.mm, height: 35.mm) do
      # pdf.stroke_bounds
      pdf.text clientINFO[:company], font_style: :bold, size: 12 unless clientINFO[:company].empty?
      %i(titre name address locality).each do |n|
        pdf.text clientINFO[n], size: 12 unless clientINFO[n].empty?
      end
    end

    # info (relative position, ~top left)
    data = [
      # { "1" => "<b>Date:</b>", "2"    => dateINFO[:now] },
      [ "Facture No:",    invoiceINFO[:id] ],
      [ "Numéro Client:", clientINFO[:id] ],
      [ "Chambre:",       clientINFO[:room] ],
      [ "Période:",       (invoiceINFO[:debut] + " au " + invoiceINFO[:fin]) ]
    ]

    pdf.bounding_box([ 0, 205.mm], width: 98.mm, height: 30.mm) do
      # pdf.stroke_bounds
      pdf.table data,
        position: :left,
        # row_colors: ['ffffff', 'eeeeee'],
        cell_style: { borders:  [], padding: [2, 2] } do

        column(0).align = :right
        column(0).font_style = :bold
      end
    end

    # invoice items table (variable lenght, starting on absolute positionning)
    data = invoice.pdf_items.map do |item|
      [ item.name, item.value.to_s ]
    end
    data.prepend [ "Prestation", "Montant" ]
    data.append [ "TOTAL (CHF)", invoice.pdf_value.to_s ]

    pdf.table data,
      position: :left,
      row_colors: ['eeeeee', 'ffffff'],
      width: 170.mm,
      cell_style: { borders:  [], size: 11, padding: [2, 2] } do

      row(0).text_color = 'ffffff'
      row(0).background_color = '888888'
      row(-1).font_style = :bold
    end

    pdf.move_down 5.mm

    # conditions
    unless invoice.is_a?(DepositInvoice)
      pdf.text "<b>Conditions:</b> Règlement à 10 jours", inline_format: true
    end
    if @bvr == true
      pdf.text "Merci d'effectuer votre règlement au moyen du bulletin de versement annexé."
    end
    pdf.move_down 3.mm
    pdf.text "Nous vous remercions de votre confiance.", :font_size => 10

    # #######################################
    # # BVR
    # #######################################

    if @bvr == true

      # Address
      x_address1 = 7.mm - margins[1]
      x_address2 = 63.mm - margins[1]
      y_address = 95.mm - margins[2]
      mw_value_address = 60.mm

      bank_address = "BANQUE CANTONALE DE GENEVE
1211 GENEVE 2

<b>T 3225.31.34</b>
Association St-Boniface
1205 Gèneve"

      [x_address1, x_address2].each do |x|
        pdf.text_box bank_address, at: [x, y_address], width: 50.mm, height: 20.mm, inline_format: true, size: 8
      end

      x_client_address1 = 7.mm - margins[1]
      y_client_address1 = 38.mm - margins[2]
      x_client_address2 = 128.mm - margins[1]
      y_client_address2 = 50.mm - margins[2]

      pdf.bounding_box([ x_client_address1, y_client_address1], width: 50.mm, height: 25.mm) do
        # pdf.stroke_bounds
        pdf.text clientINFO[:company], font_style: :bold, size: 8 unless clientINFO[:company].empty?
        %i(titre name address locality).each do |n|
          pdf.text clientINFO[n], size: 8 unless clientINFO[n].empty?
        end
      end

      pdf.bounding_box([ x_client_address2, y_client_address2], width: 50.mm, height: 25.mm) do
        # pdf.stroke_bounds
        pdf.text clientINFO[:company], font_style: :bold, size: 10 unless clientINFO[:company].empty?
        %i(titre name address locality).each do |n|
          pdf.text clientINFO[n], size: 10 unless clientINFO[n].empty?
        end
      end

      pdf.font [Rails.root, "/vendor/fonts/ocrb10.ttf"].join("/")
      x_ccp1 = 27.mm - margins[1]
      x_ccp2 = 88.mm - margins[1]
      y_ccp = 62.mm - margins[2]

      ccp = "01-47300-5"
      [ x_ccp1, x_ccp2 ].each do |x|
        pdf.text_box ccp, at: [x, y_ccp], width: 40.mm,  size: 9
      end

      # $
      x_value_francs1 = 0.mm - margins[1]
      x_value_francs2 = 63.mm - margins[1]
      x_value_cents1 = 49.mm - margins[1]
      x_value_cents2 = 110.mm - margins[1]
      y_value = 55.mm - margins[2]

      [x_value_francs1, x_value_francs2].each do |x|
        pdf.text_box monneyINFO[:francs], at: [x, y_value], width: 40.mm, size: 12, align: :right, border: true
      end
      [x_value_cents1, x_value_cents2].each do |x|
        pdf.text_box monneyINFO[:cents], at: [x, y_value], width: 40.mm, size: 12
      end

      # reference code and coding line
      x_ref = 128.mm - margins[1]
      y_ref = 70.mm - margins[2]
      pdf.text_box monneyINFO[:ref], at: [x_ref, y_ref ], width: 70.mm, size: 9

      x_mini_ref = 7.mm - margins[1]
      y_mini_ref = 44.mm - margins[2]
      pdf.text_box monneyINFO[:ref], at: [x_mini_ref, y_mini_ref ], width: 50.mm, size: 7

      # lower line (the longest)...
      x_scan = 70.mm - margins[1]# 64
      y_scan = 18.mm - margins[2]# 18
      pdf.text_box monneyINFO[:modulo], at: [x_scan, y_scan ], width: 169.mm, size: 10


    else # bank account
      pdf.move_down 15.mm
      pdf.text "<b>Coordonnées pour le versement bancaire:</b>", inline_format: true
      pdf.move_down 3.mm
      if invoice.is_a?(DepositInvoice)
        pdf.text invoice.resident.bank_name
        pdf.move_down 3.mm
        pdf.text "En faveur de"
        pdf.text invoice.resident.full_name
        pdf.move_down 3.mm
        pdf.text "IBAN : #{invoice.resident.bank_iban}"
        pdf.text "BIC: #{invoice.resident.bank_bic_swift}"
        pdf.text "CLEARING : #{invoice.resident.bank_clearing}"
      else
        pdf.text "Banque Cantonale de Genève"
        pdf.text "1211 Genève 2 - Switzerland"
        pdf.move_down 3.mm
        pdf.text "En faveur de"
        pdf.text "Association St-Boniface"
        pdf.move_down 3.mm
        pdf.text "IBAN : CH92 0078 8000 T322 5313 4"
        pdf.text "BIC: BCGECHGGXXX"
        pdf.text "CLEARING : 788"
      end
    end # if bvr

  end # invoices.each

end