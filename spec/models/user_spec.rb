require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'unique ids' do
    it 'has a unique id' do
      user = Fabricate(:user)
      expect(user.unique_id).to be_present
    end
  end

  describe 'chiefs' do
    it 'recognises chiefs' do
      expect(Fabricate(:user).is_chief?).to be false
      expect(Fabricate(:user, email: 'dan@reasonfactory.com').is_chief?).to be true
      expect(Fabricate(:user, email: 'arthure@vreel.io').is_chief?).to be true
    end
  end
end
