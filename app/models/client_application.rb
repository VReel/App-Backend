class ClientApplication < ApplicationRecord
  acts_as_paranoid

  before_create { self.application_id = SecureRandom.random_number(24**72).to_s(36) }

  validates :name, presence: true, uniqueness: true

  def self.request_valid?(request)
    request.headers['vreel-application-id'].present? &&
      AUTHORIZED_APPLICATION_IDS.include?(request.headers['vreel-application-id'])
  end
end
