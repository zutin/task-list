require 'rails_helper'

RSpec.describe 'CreateTask mutation', type: :request do
  let(:mutation) do
    <<~GQL
      mutation CreateTask($input: CreateTaskInput!) {
        createTask(input: $input) {
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

  context 'with valid params' do
    it 'creates a task and returns it' do
      expect {
        post '/graphql', params: { query: mutation, variables: { input: { title: "My task", listId: list.id, position: 1 } } }, as: :json
      }.to change(Task, :count).by(1)

      json = JSON.parse(response.body)
      data = json.dig('data', 'createTask')

      aggregate_failures "created task" do
        expect(response).to have_http_status(:ok)
        expect(data['task']['title']).to eq("My task")
        expect(data['task']['position']).to eq(1)
        expect(data['task']['completedAt']).to be_nil
        expect(data['task']['id']).to be_present
        expect(data['errors']).to be_empty
      end
    end

    it 'creates a task with optional fields' do
      due_at = 3.days.from_now.iso8601

      expect {
        post '/graphql', params: { query: mutation, variables: { input: {
          title: "Detailed task",
          listId: list.id,
          position: 1,
          description: "A description",
          dueAt: due_at
        } } }, as: :json
      }.to change(Task, :count).by(1)

      json = JSON.parse(response.body)
      data = json.dig('data', 'createTask')

      aggregate_failures "created task with optional fields" do
        expect(response).to have_http_status(:ok)
        expect(data['task']['title']).to eq("Detailed task")
        expect(data['task']['description']).to eq("A description")
        expect(data['task']['dueAt']).to be_present
        expect(data['errors']).to be_empty
      end
    end
  end

  context 'with missing title' do
    it 'returns errors and nil task' do
      expect {
        post '/graphql', params: { query: mutation, variables: { input: { title: "", listId: list.id, position: 1 } } }, as: :json
      }.not_to change(Task, :count)

      json = JSON.parse(response.body)
      data = json.dig('data', 'createTask')

      aggregate_failures "validation errors" do
        expect(response).to have_http_status(:ok)
        expect(data['task']).to be_nil
        expect(data['errors']).to include("Title can't be blank")
      end
    end
  end

  context 'with title exceeding maximum length' do
    it 'returns errors and nil task' do
      expect {
        post '/graphql', params: { query: mutation, variables: { input: { title: "a" * 256, listId: list.id, position: 1 } } }, as: :json
      }.not_to change(Task, :count)

      json = JSON.parse(response.body)
      data = json.dig('data', 'createTask')

      aggregate_failures "validation errors" do
        expect(response).to have_http_status(:ok)
        expect(data['task']).to be_nil
        expect(data['errors']).to include("Title is too long (maximum is 255 characters)")
      end
    end
  end

  context 'with invalid list' do
    it 'returns errors and nil task' do
      expect {
        post '/graphql', params: { query: mutation, variables: { input: { title: "Task", listId: 0, position: 1 } } }, as: :json
      }.not_to change(Task, :count)

      json = JSON.parse(response.body)
      data = json.dig('data', 'createTask')

      aggregate_failures "validation errors" do
        expect(response).to have_http_status(:ok)
        expect(data['task']).to be_nil
        expect(data['errors']).to include("List must exist")
      end
    end
  end
end
