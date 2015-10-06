class User < ActiveRecord::Base
  before_save { self.email = email.downcase }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,
                    uniqueness: { case_sensitive: false }
  # TODO: email regex allows invalid addresses that contain consecutive
  # dots, such as foo@bar..com.
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }
end
