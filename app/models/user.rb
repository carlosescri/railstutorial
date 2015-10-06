class User < ActiveRecord::Base
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
                                                  BCrypt::ENgine.cost
    BCrypt::Password.create(plain_password, cost: cost)
  end
end
