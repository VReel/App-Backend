require 'rails_helper'

RSpec.describe Like, type: :model do
  let!(:user) { Fabricate(:user) }
  let!(:post) { create_post(Fabricate(:user), Faker::HarryPotter.quote) }

  it 'can like a post' do
    user.like(post)

    expect(user.likes?(post)).to be true
  end

  it 'can unlike a post' do
    user.like(post)
    user.unlike(post)

    expect(user.likes?(post)).to be false
  end
end
