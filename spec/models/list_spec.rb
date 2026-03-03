require 'rails_helper'

RSpec.describe List, type: :model do
  describe 'validations' do
    let(:list) { build(:list, name: name) }
    let(:name) { 'To-do list' }

    it 'is valid with valid attributes' do
      expect(list).to be_valid
    end

    context 'presence' do
      let(:name) { nil }

      it 'is invalid without a name' do
        expect(list).to be_invalid
        expect(list.errors).to include(:name)
      end
    end

    context 'length' do
      context 'when name has exactly or lower than 100 characters' do
        let(:name) { 'a' * 100 }

        it 'is valid' do
          expect(list).to be_valid
        end
      end

      context 'when name exceeds 100 characters' do
        let(:name) { 'a' * 101 }

        it 'is invalid' do
          expect(list).to be_invalid
          expect(list.errors).to include(:name)
        end
      end
    end
  end
end
