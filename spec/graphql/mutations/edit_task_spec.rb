require 'rails_helper'

RSpec.describe 'EditTask mutation', type: :request do
  let(:mutation) do
    <<~GQL
      mutation EditTask($input: EditTaskInput!) {
        editTask(input: $input) {
          task {
            id
            title
            description
            dueAt
            completedAt
            position
          }
          errors
        }
      }
    GQL
  end

  let(:list) { create(:list, name: "My list", position: 1) }
  let(:task) { create(:task, title: "Original title", list: list, position: 1) }

  before { task }

  context 'with valid params' do
    it 'updates the task title' do
      post '/graphql', params: { query: mutation, variables: { input: { id: task.id, title: "Updated title" } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editTask')

      aggregate_failures "updated task" do
        expect(response).to have_http_status(:ok)
        expect(data['task']['title']).to eq("Updated title")
        expect(data['task']['position']).to eq(1)
        expect(data['errors']).to be_empty
      end
    end

    it 'updates the task description' do
      post '/graphql', params: { query: mutation, variables: { input: { id: task.id, description: "New description" } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editTask')

      aggregate_failures "updated task" do
        expect(response).to have_http_status(:ok)
        expect(data['task']['description']).to eq("New description")
        expect(data['errors']).to be_empty
      end
    end

    it 'updates the task position' do
      post '/graphql', params: { query: mutation, variables: { input: { id: task.id, position: 5 } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editTask')

      aggregate_failures "updated task" do
        expect(response).to have_http_status(:ok)
        expect(data['task']['position']).to eq(5)
        expect(data['errors']).to be_empty
      end
    end

    it 'marks the task as completed by setting completed_at' do
      Timecop.freeze

      post '/graphql', params: { query: mutation, variables: { input: { id: task.id, completedAt: Time.current.iso8601 } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editTask')

      aggregate_failures "completed task" do
        expect(response).to have_http_status(:ok)
        expect(data['task']['completedAt']).to eq(Time.current.iso8601)
        expect(data['errors']).to be_empty
      end
    end

    it 'marks the task as not completed by clearing completed_at' do
      task.update(completed_at: 1.day.ago)

      post '/graphql', params: { query: mutation, variables: { input: { id: task.id, completedAt: nil } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editTask')

      aggregate_failures "uncompleted task" do
        expect(response).to have_http_status(:ok)
        expect(data['task']['completedAt']).to be_nil
        expect(data['errors']).to be_empty
      end
    end

    it 'moves the task to a different list' do
      other_list = create(:list, name: "Other list", position: 2)

      post '/graphql', params: { query: mutation, variables: { input: { id: task.id, listId: other_list.id } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editTask')

      aggregate_failures "moved task" do
        expect(response).to have_http_status(:ok)
        expect(task.reload.list_id).to eq(other_list.id)
        expect(data['errors']).to be_empty
      end
    end
  end

  context 'with invalid params' do
    it 'returns errors for blank title' do
      post '/graphql', params: { query: mutation, variables: { input: { id: task.id, title: "" } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editTask')

      aggregate_failures "validation errors" do
        expect(response).to have_http_status(:ok)
        expect(data['task']).to be_nil
        expect(data['errors']).to include("Title can't be blank")
      end
    end

    it 'returns errors for title exceeding maximum length' do
      post '/graphql', params: { query: mutation, variables: { input: { id: task.id, title: "a" * 256 } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editTask')

      aggregate_failures "validation errors" do
        expect(response).to have_http_status(:ok)
        expect(data['task']).to be_nil
        expect(data['errors']).to include("Title is too long (maximum is 255 characters)")
      end
    end
  end

  context 'with non-existent task' do
    it 'returns errors' do
      post '/graphql', params: { query: mutation, variables: { input: { id: 0 } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editTask')

      aggregate_failures "not found errors" do
        expect(response).to have_http_status(:ok)
        expect(data['task']).to be_nil
        expect(data['errors']).to include("Task not found")
      end
    end
  end
end
