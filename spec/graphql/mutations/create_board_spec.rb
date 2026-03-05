require 'rails_helper'

RSpec.describe 'CreateBoard mutation', type: :request do
  let(:mutation) do
    <<~GQL
      mutation CreateBoard($input: CreateBoardInput!) {
        createBoard(input: $input) {
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

  context 'with valid params' do
    it 'creates a board and returns it' do
      expect {
        post '/graphql', params: { query: mutation, variables: { input: { name: "My board" } } }, as: :json
      }.to change(Board, :count).by(1)

      json = JSON.parse(response.body)
      data = json.dig('data', 'createBoard')

      aggregate_failures "created board" do
        expect(response).to have_http_status(:ok)
        expect(data['board']['name']).to eq("My board")
        expect(data['board']['id']).to be_present
        expect(data['errors']).to be_empty
      end
    end

    it 'creates a board with a description' do
      post '/graphql', params: { query: mutation, variables: { input: { name: "My board", description: "A description" } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'createBoard')

      aggregate_failures "created board with description" do
        expect(response).to have_http_status(:ok)
        expect(data['board']['name']).to eq("My board")
        expect(data['board']['description']).to eq("A description")
        expect(data['errors']).to be_empty
      end
    end
  end

  context 'with missing name' do
    it 'returns errors and nil board' do
      expect {
        post '/graphql', params: { query: mutation, variables: { input: { name: "" } } }, as: :json
      }.not_to change(Board, :count)

      json = JSON.parse(response.body)
      data = json.dig('data', 'createBoard')

      aggregate_failures "validation errors" do
        expect(response).to have_http_status(:ok)
        expect(data['board']).to be_nil
        expect(data['errors']).to include("Name can't be blank")
      end
    end
  end

  context 'with name exceeding maximum length' do
    it 'returns errors and nil board' do
      expect {
        post '/graphql', params: { query: mutation, variables: { input: { name: "a" * 101 } } }, as: :json
      }.not_to change(Board, :count)

      json = JSON.parse(response.body)
      data = json.dig('data', 'createBoard')

      aggregate_failures "validation errors" do
        expect(response).to have_http_status(:ok)
        expect(data['board']).to be_nil
        expect(data['errors']).to include("Name is too long (maximum is 100 characters)")
      end
    end
  end
end
