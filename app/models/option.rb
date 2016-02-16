class Option < ActiveRecord::Base
  validates_presence_of     :key
  validates_uniqueness_of   :key

  def self.value(key)
    option = self.where(key: key).first
    raise 'Cannot find option' unless option
    option.value
  end
end
