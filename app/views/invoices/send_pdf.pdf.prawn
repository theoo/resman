# Use the Variable PDF::Writer::FontMetrics::METRICS_PATH in a console to find the font path
# It's probably necessary for ocrb10 (BVR)
require "prawn/measurement_extensions"

prawn_document(top_margin: 36, left_margin: 72, bottom_margin: 36, right_margin: 36) do |pdf|

  @invoices.each_with_index do |invoice, i|

    pdf.start_new_page unless i == 0

    # pdf.font "Helvetica"
    # pdf.move_down 22
    #pdf.image "public/images/cstb.jpg", :justification => :center
    #pdf.text " ", :size => 12

    ############################################################################################
    # ALL Variables Fields in PDF
    ############################################################################################

    dateINFO = Hash.new
    dateINFO[:now]        = invoice.created_at.strftime('%d.%m.%Y').to_utf8

    clientINFO = Hash.new
    clientINFO[:id]       = invoice.resident.id.to_s.to_utf8
    clientINFO[:room]     = invoice.room.name
    clientINFO[:company]  = " "
    clientINFO[:titre]    = " "
    clientINFO[:name]     = invoice.resident.full_name.to_utf8
    clientINFO[:address]  = "Av. du Mail 14".to_utf8
    clientINFO[:locality] = "1205 Geneve".to_utf8

    invoiceINFO = Hash.new
    invoiceINFO[:id]      = invoice.id.to_s.to_utf8
    invoiceINFO[:debut]   = invoice.interval_start_formatted.to_utf8
    invoiceINFO[:fin]     = invoice.interval_end_formatted.to_utf8

    monneyINFO = Hash.new
    monneyINFO[:francs]   = invoice.pdf_value.to_s.split('.')[0].to_utf8
    monneyINFO[:cents]    = invoice.pdf_value.to_s.split('.')[1].to_utf8
    monneyINFO[:ref]      = invoice.bvr_ref.to_utf8
    monneyINFO[:modulo]   = "01" + zerofill(monneyINFO[:francs] + monneyINFO[:cents], 10) + zerofill(monneyINFO[:francs] + monneyINFO[:cents], 10).to_i.mod10rec.to_s + ">" \
                            + monneyINFO[:ref] + "+ " + "010473005>"


    #######################################
    # Invoice content
    #######################################

    # date
    pdf.bounding_box([ 90.mm, 240.mm], width: 70.mm, height: 12) do
      pdf.stroke_bounds
      pdf.font "Helvetica"
      pdf.text "Geneve, le " + dateINFO[:now], size: 12
    end

    pdf.move_down 130

    # info (relative position, ~top left)
    data = [
      # { "1" => "<b>Date:</b>", "2"    => dateINFO[:now] },
      [ "Facture No:",    invoiceINFO[:id] ],
      [ "Numéro Client:", clientINFO[:id] ],
      [ "Chambre:",       clientINFO[:room] ],
      [ "Période:",       (invoiceINFO[:debut] + " au " + invoiceINFO[:fin]) ]
    ]

    pdf.table data,
      position: :left,
      # row_colors: ['ffffff', 'eeeeee'],
      cell_style: { borders:  [], size: 10, padding: [2, 2] } do

      column(0).align = :right
      column(0).font_style = :bold
    end

    pdf.move_down 15

    pdf.bounding_box([ 90.mm, 230.mm], width: 70.mm, height: 35.mm) do
      pdf.stroke_bounds
      pdf.stroke_circle [0, 0], 10
    end

    # # client address (absolute positionning)
    # client = []
    # client << "<b>" + clientINFO[:company] + "</b>"
    # client << clientINFO[:titre]
    # client << clientINFO[:name]
    # client << clientINFO[:address]
    # client << clientINFO[:locality]
    # corner_top_left = 240.mm2pts
    # client.size.times do |n|
    #   pdf.add_text_wrap(125.mm2pts, corner_top_left - (n * 13), 70.mm2pts, client[n], 12, :justification => :left)
    # end

    # # invoice items table (variable lenght, starting on absolute positionning)
    # pdf.font "Helvetica"
    # data_for_items  = Array.new
    # invoice.pdf_items.each do |item|
    #   data_for_items << {'1' => item.name.to_utf8, '2' => item.value.to_s.to_utf8}
    # end
    # data_for_items << {'1' => "<b>TOTAL (CHF)</b>", '2' => "<b>#{invoice.pdf_value.to_s.to_utf8}</b>"}

    # items = PDF::SimpleTable.new
    # items.columns["1"] = PDF::SimpleTable::Column.new("1") { |col| col.heading = "Prestation" }
    # items.columns["2"] = PDF::SimpleTable::Column.new("2") { |col| col.heading = "Montant" }
    # items.column_order = [ "1", "2"]
    # items.data = data_for_items
    # items.show_headings = true
    # items.heading_color = Color::RGB::White
    # items.shade_headings = true
    # items.shade_heading_color = Color::RGB::Grey60
    # items.shade_rows = true
    # items.minimum_space = 100
    # items.protect_rows = 2
    # items.inner_line_style = PDF::Writer::StrokeStyle.new(0.5)
    # items.outer_line_style = PDF::Writer::StrokeStyle.new(0.5)
    # items.font_size = 10
    # items.show_lines = :none
    # items.width = pdf.page_width - pdf.right_margin - pdf.left_margin
    # items.render_on(pdf)
    # pdf.text " ", :font_size => 24

    # # conditions
    # pdf.font "Helvetica"
    # unless invoice.is_a?(DepositInvoice)
    #   pdf.text "<b>Conditions:</b> Règlement à 10 jours".to_utf8, :font_size => 10, :justification => :full
    # end
    # if @bvr == true
    #   pdf.text "Merci d'effectuer votre règlement au moyen du bulletin de versement annexé.".to_utf8, :font_size => 10, :justification => :full
    # end
    # pdf.text " ".to_utf8, :font_size => 4
    # pdf.text "Nous vous remercions de votre confiance.".to_utf8, :font_size => 10

    # #######################################
    # # BVR
    # #######################################

    # if @bvr == true

    #   # Address
    #   pdf.font "Helvetica"
    #   x_address1 = 7.mm2pts
    #   x_address2 = 63.mm2pts
    #   y_address = 95.mm2pts
    #   mw_value_address = 60.mm2pts

    #   address = Array.new
    #   tmp_address = "BANQUE CANTONALE DE GENEVE \n1211 GENEVE 2 \nEn faveur de \n<b>T 3225.31.34</b> \nAssociation St-Boniface \n1205 Gèneve"
    #   tmp_address.each_char { |a| address << a }

    #   [ x_address1, x_address2 ].each do |x|
    #     address.size.times do |n|
    #       pdf.add_text_wrap(x, y_address - (n * 10), mw_value_address, address[n].to_utf8, 8, :justification => :left)
    #     end
    #   end

    #   x_client_address1 = 7.mm2pts
    #   y_client_address1 = 38.mm2pts
    #   x_client_address2 = 128.mm2pts
    #   y_client_address2 = 50.mm2pts
    #   mw_value_address = 60.mm2pts

    #   client_address = Array.new
    #   client_address << clientINFO[:company]
    #   client_address << clientINFO[:titre]
    #   client_address << clientINFO[:name]
    #   client_address << clientINFO[:address]
    #   client_address << clientINFO[:locality]

    #   client_address.size.times do |n|
    #     pdf.add_text_wrap(x_client_address1, y_client_address1 - (n * 10), mw_value_address, client_address[n], 10, :justification => :left)
    #   end
    #   client_address.size.times do |n|
    #     pdf.add_text_wrap(x_client_address2, y_client_address2 - (n * 12), mw_value_address, client_address[n], 12, :justification => :left)
    #   end

    #   pdf.font "ocrb10" # make sure the font is installed on your system!
    #   x_ccp1 = 27.mm2pts
    #   x_ccp2 = 88.mm2pts
    #   y_ccp = 62.mm2pts
    #   mw_value_ccp = 35.mm2pts
    #   ccp = "01- 47300- 5"
    #   [ x_ccp1, x_ccp2 ].each do |x|
    #     pdf.add_text_wrap(x, y_ccp, mw_value_ccp, ccp, 10, :justification => :left)
    #   end

    #   # $
    #   x_value_francs1 = 2.mm2pts
    #   x_value_francs2 = 63.mm2pts
    #   x_value_cents1 = 49.mm2pts
    #   x_value_cents2 = 110.mm2pts
    #   y_value = 53.mm2pts
    #   mw_value_francs = 40.mm2pts
    #   mw_value_cents = 9.mm2pts

    #   pdf.add_text_wrap(x_value_francs1, y_value, mw_value_francs, monneyINFO[:francs], 12, :right) # francs
    #   pdf.add_text_wrap(x_value_cents1, y_value, mw_value_cents, monneyINFO[:cents], 12) # centimes
    #   pdf.add_text_wrap(x_value_francs2, y_value, mw_value_francs, monneyINFO[:francs], 12, :right) # francs
    #   pdf.add_text_wrap(x_value_cents2, y_value, mw_value_cents, monneyINFO[:cents], 12) # centimes

    #   # reference code and coding line
    #   x_checksum = 115.mm2pts
    #   y_checksum = 70.mm2pts
    #   mw_value_checksum = 97.mm2pts
    #   pdf.add_text_wrap(x_checksum, y_checksum, mw_value_checksum, block(monneyINFO[:ref]), 10, :right)

    #   x_mini_checksum = 7.mm2pts
    #   y_mini_checksum = 44.mm2pts
    #   mw_value_mini_checksum = 70.mm2pts
    #   pdf.add_text_wrap(x_mini_checksum, y_mini_checksum, mw_value_mini_checksum, block(monneyINFO[:ref]), 8, :left)

    #   # lower line (the longest)...
    #   x_modulo = 70.mm2pts # 64
    #   y_modulo = 18.mm2pts # 18
    #   mw_value_modulo = 169.mm2pts # 169
    #   cntr = 0
    #   monneyINFO[:modulo].scan(/./).each do |c|
    #     pdf.add_text(x_modulo + cntr * 7, y_modulo, c, 10, 0)
    #     cntr += 1
    #   end

    #   # end BVR ###################################################################################

    # else # bank account
    #    pdf.font "Helvetica"
    #    pdf.text " ", :font_size => 40
    #    pdf.text "<b>Coordonnées pour le versement bancaire:</b>".to_utf8, :font_size => 10
    #    pdf.text " ".to_utf8
    #    if invoice.is_a?(DepositInvoice)
    #      pdf.text invoice.resident.bank_name.to_utf8
    #      pdf.text " ".to_utf8
    #      pdf.text "En faveur de".to_utf8
    #      pdf.text invoice.resident.full_name.to_utf8
    #      pdf.text " ".to_utf8
    #      pdf.text "IBAN : #{invoice.resident.bank_iban}".to_utf8
    #      pdf.text "BIC: #{invoice.resident.bank_bic_swift}".to_utf8
    #      pdf.text "CLEARING : #{invoice.resident.bank_clearing}".to_utf8
    #    else
    #      pdf.text "Banque Cantonale de Genève".to_utf8
    #      pdf.text "1211 Genève 2 - Switzerland".to_utf8
    #      pdf.text " ".to_utf8
    #      pdf.text "En faveur de".to_utf8
    #      pdf.text "Association St-Boniface".to_utf8
    #      pdf.text " ".to_utf8
    #      pdf.text "IBAN : CH92 0078 8000 T322 5313 4".to_utf8
    #      pdf.text "BIC: BCGECHGGXXX".to_utf8
    #      pdf.text "CLEARING : 788".to_utf8
    #    end
    # end # if bvr

  end # invoices.each

end