class User < ActiveRecord::Base
  attr_accessor :remember_token

  before_save { email.downcase! }  # or self.email = email.downcase

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i,
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

  # Returns the hash digest for the given plain password
  def User.digest(plain_password)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(plain_password, cost: cost)
  end

  # Returns a random token
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions
  def remember
    self.remember_token = User.new_token
    # update_attribute bypasses validation!
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Forgets the user in the database. Just undoes remember().
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Returns true if the given remember token matches the stored remember digest
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
end
