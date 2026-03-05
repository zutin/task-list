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

  describe 'positioning' do
    let(:board) { create(:board) }

    it 'shifts siblings up when inserting at an existing position' do
      list_1 = create(:list, board: board, position: 1)
      list_2 = create(:list, board: board, position: 2)
      create(:list, board: board, position: 1)

      expect(list_1.reload.position).to eq(2)
      expect(list_2.reload.position).to eq(3)
    end

    it 'does not shift when inserting at the end' do
      list_1 = create(:list, board: board, position: 1)
      create(:list, board: board, position: 2)

      expect(list_1.reload.position).to eq(1)
    end

    it 'shifts siblings when moving to a lower position' do
      list_1 = create(:list, board: board, position: 1)
      list_2 = create(:list, board: board, position: 2)
      list_3 = create(:list, board: board, position: 3)

      list_3.update!(position: 1)

      expect(list_1.reload.position).to eq(2)
      expect(list_2.reload.position).to eq(3)
      expect(list_3.reload.position).to eq(1)
    end

    it 'shifts siblings when moving to a higher position' do
      list_1 = create(:list, board: board, position: 1)
      list_2 = create(:list, board: board, position: 2)
      list_3 = create(:list, board: board, position: 3)

      list_1.update!(position: 3)

      expect(list_1.reload.position).to eq(3)
      expect(list_2.reload.position).to eq(1)
      expect(list_3.reload.position).to eq(2)
    end

    it 'does not affect lists in other boards' do
      other_board = create(:board)
      other_list = create(:list, board: other_board, position: 1)
      create(:list, board: board, position: 1)
      create(:list, board: board, position: 1)

      expect(other_list.reload.position).to eq(1)
    end

    it 'closes the gap when a list is destroyed' do
      list_1 = create(:list, board: board, position: 1)
      list_2 = create(:list, board: board, position: 2)
      list_3 = create(:list, board: board, position: 3)

      list_2.destroy

      expect(list_1.reload.position).to eq(1)
      expect(list_3.reload.position).to eq(2)
    end
  end
end
