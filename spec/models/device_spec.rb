require 'rails_helper'

RSpec.describe Device, type: :model do
  describe '#create_for_user' do
    let!(:user) { Fabricate(:user) }
    let!(:player_id) { SecureRandom.uuid }

    it 'creates a new device when the device is new' do
      expect do
        Device.create_for_user(user, player_id)
      end.to change { Device.count }.by 1
    end

    it 'changes who owns the device when a new user uses it' do
      Device.create_for_user(Fabricate(:user), player_id)

      Device.create_for_user(user, player_id)

      expect(Device.find_by(player_id: player_id).user).to eq user
    end

    it 'does nothing when the device exists' do
      Device.create(user: user, player_id: player_id)

      expect do
        Device.create_for_user(user, player_id)
      end.not_to change { Device.count }

      expect(Device.find_by(player_id: player_id).user).to eq user
    end
  end
end
