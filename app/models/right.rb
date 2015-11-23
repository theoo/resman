class Right < ActiveRecord::Base

  belongs_to    :group

  validates_presence_of       :group_id, :controller, :action

  def denied?
    !self.allowed?
  end

end
