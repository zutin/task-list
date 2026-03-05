require 'rails_helper'

RSpec.describe 'GetTask query', type: :request do
  let(:query) do
    <<~GQL
      query GetTask($id: ID!) {
        task(id: $id) {
          id
          title
          description
          dueAt
          completedAt
          position
          createdAt
          updatedAt
        }
      }
    GQL
  end

  let(:list) { create(:list) }
  let(:task) { create(:task, title: "My task", description: "Details", list: list) }

  it 'returns the task by ID' do
    post '/graphql', params: { query: query, variables: { id: task.id.to_s } }

    json = JSON.parse(response.body)
    data = json.dig('data', 'task')

    aggregate_failures "task data" do
      expect(response).to have_http_status(:ok)
      expect(data['id']).to eq(task.id.to_s)
      expect(data['title']).to eq("My task")
      expect(data['description']).to eq("Details")
      expect(data['completedAt']).to be_nil
      expect(data['position']).to eq(1)
    end
  end

  it 'returns nil when the task is not found' do
    post '/graphql', params: { query: query, variables: { id: "999999" } }

    json = JSON.parse(response.body)

    expect(response).to have_http_status(:ok)
    expect(json.dig('data', 'task')).to be_nil
  end
end
