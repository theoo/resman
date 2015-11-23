class ReservationOption < ActiveRecord::Base
  belongs_to :reservation
  belongs_to :room_option
end