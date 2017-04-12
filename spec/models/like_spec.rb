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

  describe 'like_counts' do
    it 'adds one to the liked_count of the post when liked' do
      expect do
        user.like(post)
      end.to change { post.like_count }.by 1
    end

    it 'subtracts one to the liked_count of the post when liked' do
      user.like(post)

      expect do
        user.unlike(post)
      end.to change { post.reload.like_count }.by(-1)
    end
  end
end
