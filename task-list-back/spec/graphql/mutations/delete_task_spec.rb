require 'rails_helper'

RSpec.describe 'DeleteTask mutation', type: :request do
  let(:mutation) do
    <<~GQL
      mutation DeleteTask($input: DeleteTaskInput!) {
        deleteTask(input: $input) {
          id
          errors
        }
      }
    GQL
  end

  context 'with valid id' do
    let(:list) { create(:list, name: "My list", position: 1) }
    let(:task) { create(:task, title: "To delete", list: list, position: 1) }

    before { task }

    it 'deletes the task and returns its id' do
      expect {
        post '/graphql', params: { query: mutation, variables: { input: { id: task.id } } }, as: :json
      }.to change(Task, :count).by(-1)

      json = JSON.parse(response.body)
      data = json.dig('data', 'deleteTask')

      aggregate_failures "deleted task" do
        expect(response).to have_http_status(:ok)
        expect(data['id']).to eq(task.id.to_s)
        expect(data['errors']).to be_empty
      end
    end
  end

  context 'with non-existent id' do
    it 'returns errors and nil id' do
      expect {
        post '/graphql', params: { query: mutation, variables: { input: { id: 0 } } }, as: :json
      }.not_to change(Task, :count)

      json = JSON.parse(response.body)
      data = json.dig('data', 'deleteTask')

      aggregate_failures "not found errors" do
        expect(response).to have_http_status(:ok)
        expect(data['id']).to be_nil
        expect(data['errors']).to include("Task not found")
      end
    end
  end
end
