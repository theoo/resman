# TODO move this to lib and load it in models
class ActiveRecord::Base
  def self.formatted_date(*names)
    names.each do |name|
      define_method("#{name}_formatted") do
        value = self.send(name)
        (value.is_a?(Date) || value.is_a?(Time)) ? value.to_s(:formatted) : nil
      end

      define_method("#{name}_formatted=") do |value|
        if value.is_a?(String)
          self.send("#{name}=", value.to_default_date) rescue nil
        end
      end
    end
  end

  def self.log_after(*names)
=begin
    if names.include?(:destroy)
      define_method("before_destroy") { log_activity('destroy', "destroy #{self.class} #{self}") }
    end
    names.delete(:destroy)
    names.each do |name|
      define_method("after_#{name}") { log_activity(name.to_s) }
    end
=end
  end

  def log_activity(name, text = nil)
    text ||= name
    Activity.create!(user: User.current_user, entity: self, text: text)
  end
end