require 'rails_helper'

RSpec.describe 'EditBoard mutation', type: :request do
  let(:mutation) do
    <<~GQL
      mutation EditBoard($input: EditBoardInput!) {
        editBoard(input: $input) {
          board {
            id
            name
            description
          }
          errors
        }
      }
    GQL
  end
  let(:board) { create(:board, name: "Original name", description: "Original description") }

  context 'with valid params' do
    it 'updates the board name' do
      post '/graphql', params: { query: mutation, variables: { input: { id: board.id, name: "Updated name" } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editBoard')

      aggregate_failures "updated board" do
        expect(response).to have_http_status(:ok)
        expect(data['board']['name']).to eq("Updated name")
        expect(data['board']['description']).to eq("Original description")
        expect(data['errors']).to be_empty
      end
    end

    it 'updates the board description' do
      post '/graphql', params: { query: mutation, variables: { input: { id: board.id, description: "Updated description" } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editBoard')

      aggregate_failures "updated board" do
        expect(response).to have_http_status(:ok)
        expect(data['board']['name']).to eq("Original name")
        expect(data['board']['description']).to eq("Updated description")
        expect(data['errors']).to be_empty
      end
    end

    it 'updates both name and description' do
      post '/graphql', params: { query: mutation, variables: { input: { id: board.id, name: "New name", description: "New description" } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editBoard')

      aggregate_failures "updated board" do
        expect(response).to have_http_status(:ok)
        expect(data['board']['name']).to eq("New name")
        expect(data['board']['description']).to eq("New description")
        expect(data['errors']).to be_empty
      end
    end
  end

  context 'with invalid params' do
    it 'returns errors for blank name' do
      post '/graphql', params: { query: mutation, variables: { input: { id: board.id, name: "" } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editBoard')

      aggregate_failures "validation errors" do
        expect(response).to have_http_status(:ok)
        expect(data['board']).to be_nil
        expect(data['errors']).to include("Name can't be blank")
      end
    end

    it 'returns errors for name exceeding maximum length' do
      post '/graphql', params: { query: mutation, variables: { input: { id: board.id, name: "a" * 101 } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editBoard')

      aggregate_failures "validation errors" do
        expect(response).to have_http_status(:ok)
        expect(data['board']).to be_nil
        expect(data['errors']).to include("Name is too long (maximum is 100 characters)")
      end
    end
  end

  context 'with non-existent board' do
    it 'returns errors' do
      post '/graphql', params: { query: mutation, variables: { input: { id: 0 } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editBoard')

      aggregate_failures "not found errors" do
        expect(response).to have_http_status(:ok)
        expect(data['board']).to be_nil
        expect(data['errors']).to include("Board not found")
      end
    end
  end
end
