require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'unique ids' do
    it 'has a unique id' do
      user = Fabricate(:user)
      expect(user.unique_id).to be_present
    end
  end
end
