require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validations' do
    let(:task) { build(:task, title: title, description: description) }
    let(:title) { 'New task' }
    let(:description) { 'Stay hydrated' }

    it 'is valid with valid attributes' do
      expect(task).to be_valid
    end

    context 'presence' do
      let(:title) { nil }

      it 'is invalid without a title' do
        expect(task).to be_invalid
        expect(task.errors).to include(:title)
      end
    end

    context 'length' do
      context 'when title has exactly or lower than 255 characters' do
        let(:title) { 'a' * 255 }

        it 'is valid' do
          expect(task).to be_valid
        end
      end

      context 'when title exceeds 255 characters' do
        let(:title) { 'a' * 256 }

        it 'is invalid' do
          expect(task).to be_invalid
          expect(task.errors).to include(:title)
        end
      end
    end

    context 'description' do
      context 'when description has exactly or lower than 3000 characters' do
        let(:description) { 'a' * 3000 }

        it 'is valid' do
          expect(task).to be_valid
        end
      end

      context 'when description exceeds 3000 characters' do
        let(:description) { 'a' * 3001 }

        it 'is invalid' do
          expect(task).to be_invalid
          expect(task.errors).to include(:description)
        end
      end
    end
  end

  describe 'positioning' do
    let(:list) { create(:list) }

    it 'shifts siblings up when inserting at an existing position' do
      task_1 = create(:task, list: list, position: 1)
      task_2 = create(:task, list: list, position: 2)
      create(:task, list: list, position: 1)

      expect(task_1.reload.position).to eq(2)
      expect(task_2.reload.position).to eq(3)
    end

    it 'does not shift when inserting at the end' do
      task_1 = create(:task, list: list, position: 1)
      create(:task, list: list, position: 2)

      expect(task_1.reload.position).to eq(1)
    end

    it 'shifts siblings when moving to a lower position' do
      task_1 = create(:task, list: list, position: 1)
      task_2 = create(:task, list: list, position: 2)
      task_3 = create(:task, list: list, position: 3)

      task_3.update!(position: 1)

      expect(task_1.reload.position).to eq(2)
      expect(task_2.reload.position).to eq(3)
      expect(task_3.reload.position).to eq(1)
    end

    it 'shifts siblings when moving to a higher position' do
      task_1 = create(:task, list: list, position: 1)
      task_2 = create(:task, list: list, position: 2)
      task_3 = create(:task, list: list, position: 3)

      task_1.update!(position: 3)

      expect(task_1.reload.position).to eq(3)
      expect(task_2.reload.position).to eq(1)
      expect(task_3.reload.position).to eq(2)
    end

    it 'adjusts positions when moving to a different list' do
      other_list = create(:list, board: list.board, position: 2)
      task_1 = create(:task, list: list, position: 1)
      task_2 = create(:task, list: list, position: 2)
      other_task = create(:task, list: other_list, position: 1)

      task_1.update!(list: other_list, position: 1)

      expect(task_2.reload.position).to eq(1)
      expect(other_task.reload.position).to eq(2)
      expect(task_1.reload.position).to eq(1)
    end

    it 'does not affect tasks in other lists' do
      other_list = create(:list, board: list.board, position: 2)
      other_task = create(:task, list: other_list, position: 1)
      create(:task, list: list, position: 1)
      create(:task, list: list, position: 1)

      expect(other_task.reload.position).to eq(1)
    end

    it 'closes the gap when a task is destroyed' do
      task_1 = create(:task, list: list, position: 1)
      task_2 = create(:task, list: list, position: 2)
      task_3 = create(:task, list: list, position: 3)

      task_2.destroy

      expect(task_1.reload.position).to eq(1)
      expect(task_3.reload.position).to eq(2)
    end
  end
end
