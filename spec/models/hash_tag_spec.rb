require 'rails_helper'

RSpec.describe HashTag, type: :model do
  describe '#find_in' do
    it 'finds a single hash tag' do
      expect(HashTag.find_in('This string contains a #single hash tag')).to eq ['single']
    end

    it 'finds multiple hash tags' do
      expect(HashTag.find_in('This string contains a #two #hash tag')).to eq ['two', 'hash']
    end

    it 'finds multiple hash tags surrounded by punctuation' do
      expect(HashTag.find_in('This string contains a #two. #hash tag')).to eq ['two', 'hash']
    end

    it 'finds consecutive hash tags' do
      expect(HashTag.find_in('This string contains a #two#hash #tag')).to eq ['two', 'hash', 'tag']
    end

    it 'downcases hash tags' do
      expect(HashTag.find_in('This string #Paris #FRA')).to eq ['paris', 'fra']
    end
  end
end
