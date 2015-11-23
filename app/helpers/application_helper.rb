module ApplicationHelper
  def search_url(controller, conditions)
    hash = searchlogic_params
    hash[:controller] = controller
    hash[:search] ||= {}
    hash[:search][:conditions] ||= {}
    hash[:search][:conditions].merge!(conditions)
    hash
  end

  def calendar(name)
    image = image_tag "dhtml_calendar/calendar.gif", engine: :dhtml_calendar, id: "#{name}_calendar", style: 'cursor: pointer;', title: 'Click to Show Calendar
      or try these Shortcuts:
          today (tod)
          tomorrow (tom)
          yesterday
          6 (6th or 6th October)
          3rd of Feb
          10th Feb 2004
          14th of Februrary
          12 feb
          mon
          next mon
          last mon
          2004-04-04
          1/24/2005 (US)
          4/26
          10-24-2005" />'

    format = ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS[:formatted]
    javascript = javascript_tag "Calendar.setup({ popup:true,ifFormat:'#{format}',inputField:'#{name}',button:'#{name}_calendar' });"
    "#{image}#{javascript}"
  end

  def entity_url(entity)
    send("#{entity.class.to_s.downcase}_path", entity)
  end

  def shorten (string, word_limit = 3)
    words = string.split(/\s/)
    if words.size >= word_limit
      words[0,(word_limit)].join(" ") + '...'
    else
      string
    end
  end

  def controllers
    arr  = Dir["#{RAILS_ROOT}/app/controllers/*_controller.rb"]
    arr  = arr.map { |c| File.basename(c)[/(.*?)_controller.rb/, 1] }
    arr -= %w{sessions}
    arr.sort.map { |c| "#{c.camelize}Controller".constantize }
  end

  def zerofill(s, len)
    "0" * (len - s.to_s.length) + s.to_s
  end

  def block(char) # used in send_pdf.rpdf EEEEW
    char.scan(/(..)(.....)(.....)(.....)(.....)(.....)/)[0].collect { |b| b + " " }.to_s
  end

  def confirmation_invoice_path(*args)
    invoice_path(*args)
  end
  def reservation_invoice_path(*args)
    invoice_path(*args)
  end
  def deposit_invoice_path(*args)
    invoice_path(*args)
  end
  def custom_invoice_path(*args)
    invoice_path(*args)
  end

  def order_by_link(to, args = {})

    text = args[:text] ? args[:text] : to.to_s
    text = text.capitalize

    params[:order] ||= {}
    dir = params[:order][:dir] ? (! eval(params[:order][:dir])).to_s : "false"
    # params[:order] ||= {:dir => "false"}

    new_params = params.merge(order: {dir: dir, attr: to})

    link_to( text, new_params )
  end


  #   # Hack so right works (this is very ugly)
  #   menu.reject do |m|
  #     tmp = m[0][1]
  #     unless current_user.has_access?("#{tmp[:controller].camelize}Controller", tmp[:action])
  #       right = current_user.rights.find(:first, :conditions => { :controller => "#{tmp[:controller].camelize}Controller", :allowed => true })
  #       if right
  #         tmp[:action] = right.action
  #       elsif tmp[:controller] == 'overview'
  #         right = current_user.rights.find(:first, :conditions => { :controller => "InvoicesController", :allowed => true })
  #         if right
  #           tmp[:controller] = 'invoices'
  #           tmp[:action] = right.action
  #         end
  #       end
  #     end

  #     m[1] = m[1].select do |s|
  #       current_user.has_access?("#{s[1][:controller].camelize}Controller", s[1][:action])
  #     end
  #     m[1].compact.empty?
  #   end


end
