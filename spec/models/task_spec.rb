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
end
