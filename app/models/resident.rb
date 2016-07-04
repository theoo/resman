class Resident < ActiveRecord::Base

  include ScopeExtention
  extend  ScopeExtention::ClassMethods

  Genders = %w{ man woman }

  acts_as_taggable

  belongs_to  :country
  belongs_to  :religion
  belongs_to  :school

  has_one     :continent, through: :country
  has_one     :institute, through: :school
  has_many    :reservations, -> { order('arrival, departure') }, dependent: :destroy

  has_many    :invoices, through: :reservations
  has_many    :incomes, through: :invoices

  has_many    :comments, as: :entity, dependent: :destroy

  validates_presence_of   :first_name, :last_name
  validates_uniqueness_of :first_name, scope: :last_name

  formatted_date :birthdate
  log_after :create, :update, :destroy

  before_destroy :cleanup_tags

  before_save do
    if tag_list.include?("Archive") or tag_list.include?("Admin")
      tag_list.delete("Active")
    else
      tag_list << "Active"
    end
  end

  scope :men, -> { where(gender: 'man').order('last_name,first_name ASC') }
  scope :women, -> { where(gender: 'woman').order('last_name,first_name ASC') }
  scope :unknown, -> { where(gender: '').order('last_name,first_name ASC') }

  scope :reserved, -> (from, to) {
    joins(:reservations, :tags)
      .where("? <= arrival AND departure < ?", from, to)
      .where.not("tags.name" => Option.value('tag_to_ignore'))
      .uniq
  }

  def cleanup_tags
    # reset tags relationship to cleanup join table.
    self.tag_list = []
  end

  class << self

    def decompose_full_name(str)
      arr = str.split
      { last_name: arr.shift, first_name: arr.join(' ') }
    end

    def find_by_full_name(str)
      hash = decompose_full_name(str)
      # TODO remove once tested
      # find_all, conditions: { last_name_like: hash[:last_name],
      # first_name_like: hash[:first_name].split.last })
      results = where("last_name LIKE ? AND first_name LIKE ?",
        hash[:last_name], hash[:first_name].split.last)
      results.each do |r|
        return r if r.full_name == str
      end
      nil
    end

    def options_for_select(hash = {})
      arr = order('last_name, first_name').map { |r| [r.full_name, r.id] }
      arr.unshift([hash[:text] || 'All', nil]) if hash[:allow_nil]
      arr
    end

  end

  def full_name
    "#{self.last_name} #{self.first_name}"
  end

  def full_name=(str)
    hash = self.class.decompose_full_name(str)
    self.first_name, self.last_name = hash[:first_name], hash[:last_name]
  end

  def reservation_at(date)
    reservations_at(date).first
  end

  def reservations_at(date)
    reservations.where("arrival <= ? AND ? < departure", date, date)
  end

  def deletable?
    self.reservations.empty?
  end

  def to_s
    self.full_name
  end
end
