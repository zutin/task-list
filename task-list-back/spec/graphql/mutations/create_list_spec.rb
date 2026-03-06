require 'rails_helper'

RSpec.describe 'CreateList mutation', type: :request do
  let(:mutation) do
    <<~GQL
      mutation CreateList($input: CreateListInput!) {
        createList(input: $input) {
          list {
            id
            name
            position
          }
          errors
        }
      }
    GQL
  end
  let(:board) { create(:board, name: "My board") }

  context 'with valid params' do
    it 'creates a list and returns it' do
      expect {
        post '/graphql', params: { query: mutation, variables: { input: { name: "My list", position: 1, boardId: board.id } } }, as: :json
      }.to change(List, :count).by(1)

      json = JSON.parse(response.body)
      data = json.dig('data', 'createList')

      aggregate_failures "created list" do
        expect(response).to have_http_status(:ok)
        expect(data['list']['name']).to eq("My list")
        expect(data['list']['position']).to eq(1)
        expect(data['list']['id']).to be_present
        expect(data['errors']).to be_empty
      end
    end
  end

  context 'with missing name' do
    it 'returns errors and nil list' do
      expect {
        post '/graphql', params: { query: mutation, variables: { input: { name: "", position: 1, boardId: board.id } } }, as: :json
      }.not_to change(List, :count)

      json = JSON.parse(response.body)
      data = json.dig('data', 'createList')

      aggregate_failures "validation errors" do
        expect(response).to have_http_status(:ok)
        expect(data['list']).to be_nil
        expect(data['errors']).to include("Name can't be blank")
      end
    end
  end

  context 'with name exceeding maximum length' do
    it 'returns errors and nil list' do
      expect {
        post '/graphql', params: { query: mutation, variables: { input: { name: "a" * 101, position: 1, boardId: board.id } } }, as: :json
      }.not_to change(List, :count)

      json = JSON.parse(response.body)
      data = json.dig('data', 'createList')

      aggregate_failures "validation errors" do
        expect(response).to have_http_status(:ok)
        expect(data['list']).to be_nil
        expect(data['errors']).to include("Name is too long (maximum is 100 characters)")
      end
    end
  end
end
