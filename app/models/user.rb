class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy

  # following
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed

  # followers
  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "followed_id",
                                   dependent: :destroy
  has_many :followers, through: :passive_relationships, source: :follower


  attr_accessor :remember_token, :activation_token, :reset_token

  before_save :downcase_email # { email.downcase! } or { self.email = email.downcase }
  before_create :create_activation_digest

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i,
                    uniqueness: { case_sensitive: false }
  has_secure_password
  # has_secure_password includes a separate presence validation that specifically
  # catches nil passwords. Because nil passwords now bypass the main presence
  # validation but are still caught by has_secure_password, this also fixes the
  # duplicate error message.
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

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
  def authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # Activates an account
  def activate
    # Makes only one transaction
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Sends activation email
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def feed
    # following_ids is the same as self.following.map(&:id) and is
    # provided by Rails
    Micropost.where('user_id IN (?) or user_id = ?', following_ids, id)
  end

  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  def following?(other_user)
    following.include?(other_user)
  end

  private

    # Converts email field to lowercase
    def downcase_email
      self.email = email.downcase
    end

    # Creates and assigns the activation token and digest.
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
