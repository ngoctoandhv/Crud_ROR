class User < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, length: {maximum: 255}
  validates :email, uniqueness: true

  before_save {self.email = email.downcase}

  has_secure_password

  attr_accessor :remember_token, :activation_token, :reset_token

  before_create :create_activation_digest

  has_many :microposts, dependent: :destroy

  has_many :active_relationships, class_name: Relationship.name,
    foreign_key: :follower_id, dependent: :destroy
  has_many :passive_relationships, class_name: Relationship.name,
    foreign_key: :followed_id, dependent: :destroy

  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

    # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
      BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  class << self
    def new_token
      SecureRandom.urlsafe_base64
    end
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
        BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
  end

  def authenticated? remember_token
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_attribute :remember_digest, nil
  end

  # Returns true if the given token matches the digest.
  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password? token
  end

    # Activates an account.
  def activate
    update_attributes( activated: true,activated_at: Time.zone.now)
  end
  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  
  def feed
    Micropost.where "user_id = ?", id
  end

  def follow(other_user) # Follows a user.
    following << other_user
  end

  def unfollow(other_user) # Unfollows a user.
    following.delete(other_user)
  end

  def following?(other_user) # Returns if the current user is following the other_user or not
    following.include?(other_user)
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 5.minutes.ago
  end


  # def account_activation_expired?
  #   activated_at < 5.minutes.ago
  # end

  private

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token  = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

end
