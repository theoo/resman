class Resident < ActiveRecord::Base

  include ScopeExtention
  extend  ScopeExtention::ClassMethods

  Genders = %w{ man woman }

  acts_as_taggable

  belongs_to  :country
  belongs_to  :religion
  belongs_to  :school

  has_many    :reservations, dependent: :destroy, order: 'arrival, departure'

  has_many    :invoices, through: :reservations
  has_many    :incomes, through: :invoices

  has_many    :comments, as: :entity, dependent: :destroy

  validates_presence_of   :first_name, :last_name
  validates_uniqueness_of :first_name, scope: :last_name

  formatted_date :birthdate
  log_after :create, :update, :destroy

  before_destroy :cleanup_tags

  scope :men, where(gender: 'man').order('last_name,first_name ASC')
  scope :women, where(gender: 'woman').order('last_name,first_name ASC')
  scope :unknown, where(gender: '').order('last_name,first_name ASC')

  def cleanup_tags
    # reset tags relationship to cleanup join table.
    self.tag_list = []
  end

  def self.decompose_full_name(str)
    arr = str.split
    { last_name: arr.shift, first_name: arr.join(' ') }
  end

  def self.find_by_full_name(str)
    hash = decompose_full_name(str)
    results = self.find(:all, conditions: { last_name_like: hash[:last_name], first_name_like: hash[:first_name].split.last })
    results.each do |r|
      return r if r.full_name == str
    end
    nil
  end

  def self.options_for_select(hash = {})
    arr = self.order('last_name, first_name').map { |r| [r.full_name, r.id] }
    arr.unshift([hash[:text] || 'All', nil]) if hash[:allow_nil]
    arr
  end

  def continent
    return nil unless country
    country.continent
  end

  def institute
    return nil unless school
    school.institute
  end

  def full_name
    "#{self.last_name} #{self.first_name}"
  end

  def full_name=(str)
    hash = self.class.decompose_full_name(str)
    self.first_name, self.last_name = hash[:first_name], hash[:last_name]
  end

  def reservation_at(date)
    self.reservations_at(date).first
  end

  def reservations_at(date)
    self.reservations.find(:all, conditions: { arrival_lte: date, departure_gt: date })
  end

  def deletable?
    self.reservations.empty?
  end

  def to_s
    self.full_name
  end
end
