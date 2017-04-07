require 'rails_helper'

RSpec.describe Follow, type: :model do
  let!(:dan) { Fabricate(:user) }
  let!(:arthur) { Fabricate(:user) }
  let!(:simone) { Fabricate(:user) }

  describe 'relations' do
    it 'no one follows anyone' do
      expect(dan.follows?(arthur)).to be false
      expect(arthur.follows?(dan)).to be false

      expect(simone.follows?(dan)).to be false
      expect(simone.follows?(arthur)).to be false
    end

    it 'arthur can follow dan' do
      arthur.follow(dan)

      expect(dan.follows?(arthur)).to be false
      expect(arthur.follows?(dan)).to be true

      expect(simone.follows?(dan)).to be false
      expect(simone.follows?(arthur)).to be false
    end

    it 'dan can follow arthur' do
      dan.follow(arthur)

      expect(dan.follows?(arthur)).to be true
      expect(arthur.follows?(dan)).to be false

      expect(simone.follows?(dan)).to be false
      expect(simone.follows?(arthur)).to be false
    end

    it 'dan and arthur can follow each other' do
      dan.follow(arthur)
      arthur.follow(dan)

      expect(dan.follows?(arthur)).to be true
      expect(arthur.follows?(dan)).to be true

      expect(simone.follows?(dan)).to be false
      expect(simone.follows?(arthur)).to be false
    end

    it 'dan can follow arthur and simone' do
      dan.follow(arthur)
      dan.follow(simone)

      expect(dan.follows?(arthur)).to be true
      expect(arthur.follows?(dan)).to be false

      expect(dan.follows?(simone)).to be true
      expect(simone.follows?(dan)).to be false
    end

    it 'dan can unfollow arthur' do
      dan.follow(arthur)
      arthur.follow(dan)

      expect(dan.follows?(arthur)).to be true
      expect(arthur.follows?(dan)).to be true

      dan.unfollow(arthur)

      expect(dan.follows?(arthur)).to be false
      expect(arthur.follows?(dan)).to be true
    end
  end
end
