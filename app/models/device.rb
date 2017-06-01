class Device < ApplicationRecord
  belongs_to :user

  validates :player_id, presence: true
  validates :player_id, format: { with: /\A[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}\z/i }

  def self.create_for_user(user, player_id)
    return if player_id.blank?

    existing = find_by(player_id: player_id)
    # Device already exists for user.
    return existing if existing.present? && existing.user_id == user.id
    # A new user must have signed in on an existing device, so update who owns the device.
    return existing.update(user_id: user.id) && existing if existing.present?
    # New device we have not seen before.
    create(user: user, player_id: player_id)
  end
end
