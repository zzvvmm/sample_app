class User < ApplicationRecord
  attr_accessor :remember_token
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :name, presence: true, length: {maximum: Settings.name_max}
  validates :email, presence: true, length: {maximum: Settings.email_max},
                    format: {with: VALID_EMAIL_REGEX},
                    uniqueness: {case_sensitive: false}
  validates :password, presence: true,
                      length: {minimum: Settings.pass_min},
                      allow_nil: true

  has_secure_password

  before_save :email_downcase

  class << self
    def digest string
      cost = BCrypt::Engine::MIN_COST if ActiveModel::SecurePassword.min_cost
      cost = BCrypt::Engine.cost unless ActiveModel::SecurePassword.min_cost
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    @remember_token = User.new_token
    update_attributes remember_digest: User.digest(remember_token)
  end

  def authenticated? remember_token
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_attributes remember_digest: nil
  end

  private
  def email_downcase
    email.downcase!
  end
end
