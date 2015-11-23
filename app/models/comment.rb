class Comment < ActiveRecord::Base
  belongs_to  :user
  belongs_to  :entity,
    polymorphic: true

  validates_presence_of   :text

  formatted_date :created_at
end