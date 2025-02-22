class User < ApplicationRecord
  include S3Urls
  include LockedIncrementDecrement
  acts_as_paranoid

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  include DeviseTokenAuth::Concerns::User

  validates :email, presence: true
  validates :handle, presence: true
  validates :handle, presence: true, uniqueness: { case_sensitive: false }, if: :handle_changed?
  validates :handle, format: { with: /\A[a-z0-9_]{3,}\z/i, message: '%{value} - is invalid' }
  validates :profile, length: { maximum: 500 }
  validates :name, length: { maximum: 100 }
  # Both keys need to be present or blank
  validates :thumbnail_key, presence: true, if: :original_key?
  validates :original_key, presence: true, if: :thumbnail_key?
  validate :valid_keys

  # Use this if we want to require a password confirmation at the model level.
  validates :password_confirmation, presence: true, if: :password_required?

  before_create { self.unique_id = SecureRandom.random_number(36**12).to_s(36) }
  before_destroy do
    UserDeletionService.new(id).delay.delete!
  end

  has_many :posts, -> { order('created_at DESC') }

  has_many :following_relationships, -> { order('created_at DESC') }, class_name: 'Follow', foreign_key: :follower_id
  has_many :follower_relationships, -> { order('created_at DESC') }, class_name: 'Follow', foreign_key: :following_id
  has_many :following, through: :following_relationships
  has_many :followers, through: :follower_relationships
  has_many :likes
  has_many :liked_posts, through: :likes, source: :post
  has_many :comments
  has_many :devices

  def self.search(term, limit: 10)
    # Get handle matches - starting substring.
    matches = User.where('handle ilike ?', "#{term}%").limit(limit).to_a
    # Get name matches - start of string, or string following space.
    if matches.size < limit
      matches += User.where(
        'name ilike ? or name ilike ?', "#{term}%", "% #{term}%"
      ).limit(limit - matches.size).to_a
    end

    matches.uniq
  end

  def self.hash_to_uid(email)
    Digest::SHA256.hexdigest(email)
  end

  # login with email or handle
  # https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-sign-in-using-their-username-or-email-address
  attr_writer :login

  def login
    @login || handle || email
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Rails/FindBy
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    login = conditions.delete(:login)
    if login
      if login[Devise.email_regexp]
        where(conditions.to_h).where(['email = :value', { value: login.downcase }]).first
      else
        where(conditions.to_h).where(['lower(handle) = :value', { value: login.downcase }]).first
      end
    elsif conditions.key?(:handle) || conditions.key?(:email)
      where(conditions.to_h).first
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Rails/FindBy

  # Ovverride to send emails async via delayed job.
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  # Override this as we don't need to expose auth tokens in URLs right now.
  def build_auth_url(base_url, _args)
    base_url
  end

  # Override to ensure tokens keep created_at time.
  # rubocop:disable all
  def create_new_auth_token(client_id=nil)
    client_id  ||= SecureRandom.urlsafe_base64(nil, false)
    last_token ||= nil
    token        = SecureRandom.urlsafe_base64(nil, false)
    token_hash   = ::BCrypt::Password.create(token)
    expiry       = (Time.zone.now + DeviseTokenAuth.token_lifespan).to_i

    if self.tokens[client_id] && self.tokens[client_id]['token']
      last_token = self.tokens[client_id]['token']
    end

    now = Time.zone.now

    self.tokens[client_id] = {
      token:      token_hash,
      expiry:     expiry,
      last_token: last_token,
      updated_at: now,
      created_at: now.to_i
    }

    return build_auth_header(token, client_id)
  end
  # rubocop:enable all

  def is_chief?
    CHIEF_EMAIL_DOMAINS.include? email.split('@').last
  end

  def follow(user)
    following << user
  end

  def unfollow(user)
    following.destroy(user)
  end

  def follows?(user)
    following.include?(user)
  end

  def like(post)
    liked_posts << post
  end

  def unlike(post)
    liked_posts.destroy(post)
  end

  def likes?(post)
    liked_posts.include?(post)
  end

  def device_ids
    devices.map(&:player_id)
  end

  def fix_counts!
    update(post_count: posts.count, following_count: following.count, follower_count: followers.count)
  end

  protected

  def s3_folder
    unique_id
  end

  # Override email as uid.
  def sync_uid
    self.uid = User.hash_to_uid(email) if provider == 'email'
  end
end
