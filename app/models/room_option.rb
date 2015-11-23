class RoomOption < ActiveRecord::Base

  extend  MoneyComposer

  Types = %w{ unique mensual }

  belongs_to  :room
  has_many    :reservation_options, dependent: :destroy
  has_many    :reservations, through: :reservation_options

  money :value, currency: false

  validates_presence_of       :room_id
  validates_presence_of       :name
  validates_uniqueness_of     :name, scope: :room_id
  validates_inclusion_of      :billing, in: Types

  def validate
    errors.add :value, 'must be positive' unless self.value > 0.to_money
  end

  def deletable?
    self.reservation_options.empty?
  end

  def to_s
    "#{self.name} (CHF #{self.value.to_s}, billing #{self.billing})"
  end
end
