# This is named Activity instead of Log
# because there's a name conflict with rails

class Activity < ActiveRecord::Base
  belongs_to    :user
  belongs_to    :entity, polymorphic: true

  validates_presence_of   :user_id
  validates_presence_of   :entity_id
  validates_presence_of   :entity_type

  formatted_date :created_at
end
