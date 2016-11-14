require 'digest/sha1'

class User < ActiveRecord::Base

  public

    # Generated using 'rake secret'
    SALT = 'f4beb53abfb9b5437d8bf1f9a296479bb5b466fd'

    attr_accessor :password

    belongs_to  :group

    has_many    :comments, dependent: :destroy

    validates_length_of     :password, minimum: 4, if: :password_encryption_needed?
    validates_presence_of   :login, :group_id
    validates_uniqueness_of :login

    before_save :encrypt_password, if: :password_encryption_needed?

    log_after :create, :update, :destroy

    class << self
      attr_accessor :current_user
    end

    def self.authenticate(login, password)
      User.where(login: login, password_hash: encrypt_password(password)).try(:first)
    end

    def self.encrypt_password(password)
      Digest::SHA1.hexdigest("#{password}#{SALT}")
    end

    def full_name
      "#{self.last_name} #{self.first_name}"
    end

    def rights
      self.group.rights
    end

    def right_for(controller, action)
      self.group.right_for(controller, action)
    end

    def has_access?(controller, action)
      self.group.has_access?(controller, action)
    end

    def to_s
      str = "#{login}"
      str << "(#{full_name})" unless full_name.blank?
      str
    end

  private

    # Automatically encrypt the 'password' if it's set.
    def encrypt_password
      self.password_hash = self.class.encrypt_password(self.password)
    end

    # Check if password encryption is required
    def password_encryption_needed?
      new_record? || !self.password.blank?
    end

end
