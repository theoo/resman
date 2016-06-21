module ApplicationHelper

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
    arr  = Dir["#{Rails.root}/app/controllers/*_controller.rb"]
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
    text = args[:text] ? args[:text] : to.to_s.humanize
    sort_link(@q, to, text, default_order: :desc)
  end

  def current_page?(*args)

    args.each do |page|
      return true if super(page)
    end

    false

  end

  # build the container for error messages
  def error_messages_for(obj)
    return if obj.nil?
    if obj.errors && obj.errors.any?
      haml_tag :div, id: 'errorExplanation' do
        haml_tag :h2 do
          haml_concat "#{obj.errors.count} errors(s) prevented from saving."
        end
        haml_tag :br
        haml_tag :ul do
          obj.errors.messages.each_pair do |key,msg|
            haml_tag :li do
              haml_tag :b, key.to_s.humanize + ":"
              haml_concat msg.join(", ")
            end
          end
        end
      end
    end
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
