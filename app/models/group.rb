class Group < ActiveRecord::Base

  has_many :users,
    dependent: :destroy
  has_many :rights,
    -> { where(allowed: true) },
    dependent: :destroy

  validates_presence_of       :name

  log_after :create, :update, :destroy

  def self.options_for_select(hash = {})
    arr = all.order(:name).map { |g| [g.name, g.id] }
    arr.unshift([hash[:text] || 'All', nil]) if hash[:allow_nil]
    arr
  end

  def right_for(controller, action)
   # What follows is a speed hack
    unless @rights_cache
      @rights_cache = self.rights.inject({}) do |hash, r|
        hash[r.controller] ||= {}
        hash[r.controller][r.action] = r
        hash
      end
    end
    return @rights_cache[controller][action] if @rights_cache[controller] && @rights_cache[controller][action]
    Right.new(group: self, controller: controller, action: action, allowed: false)
    #right = self.rights.find(:first, :conditions => { :controller => controller, :action => action })
    #right || Right.new(:group => self, :controller => controller, :action => action, :allowed => false)
  end

  def has_access?(controller, action)
    self.right_for(controller, action).allowed?
  end

  def deletable?
    self.users.empty?
  end
end
