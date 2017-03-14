class User < ApplicationRecord
  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  include DeviseTokenAuth::Concerns::User

  validates :handle, presence: true
  validates :handle, presence: true, uniqueness: { case_sensitive: false }, if: :handle_changed?
  validates :handle, format: { with: /\A[a-z0-9_]{3,}\z/i, message: '%{value} - is invalid' }

  # Use this if we want to require a password confirmation at the model level.
  validates :password_confirmation, presence: true, if: :password_required?

  before_create { self.unique_id = SecureRandom.random_number(36**12).to_s(36) }

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

  # Override this as we don't need to expose auth tokens in URLs right now.
  def build_auth_url(base_url, _args)
    base_url
  end

  protected

  # Override email as uid.
  def sync_uid
    self.uid = User.hash_to_uid(email) if provider == 'email'
  end
end
