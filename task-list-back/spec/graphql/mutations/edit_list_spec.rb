require 'rails_helper'

RSpec.describe 'EditList mutation', type: :request do
  let(:mutation) do
    <<~GQL
      mutation EditList($input: EditListInput!) {
        editList(input: $input) {
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
  let(:list) { create(:list, name: "Original name", position: 1) }

  context 'with valid params' do
    it 'updates the list name' do
      post '/graphql', params: { query: mutation, variables: { input: { id: list.id, name: "Updated name" } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editList')

      aggregate_failures "updated list" do
        expect(response).to have_http_status(:ok)
        expect(data['list']['name']).to eq("Updated name")
        expect(data['list']['position']).to eq(1)
        expect(data['errors']).to be_empty
      end
    end

    it 'updates the list position' do
      post '/graphql', params: { query: mutation, variables: { input: { id: list.id, position: 5 } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editList')

      aggregate_failures "updated list" do
        expect(response).to have_http_status(:ok)
        expect(data['list']['name']).to eq("Original name")
        expect(data['list']['position']).to eq(5)
        expect(data['errors']).to be_empty
      end
    end

    it 'updates both name and position' do
      post '/graphql', params: { query: mutation, variables: { input: { id: list.id, name: "New name", position: 3 } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editList')

      aggregate_failures "updated list" do
        expect(response).to have_http_status(:ok)
        expect(data['list']['name']).to eq("New name")
        expect(data['list']['position']).to eq(3)
        expect(data['errors']).to be_empty
      end
    end
  end

  context 'with invalid params' do
    it 'returns errors for blank name' do
      post '/graphql', params: { query: mutation, variables: { input: { id: list.id, name: "" } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editList')

      aggregate_failures "validation errors" do
        expect(response).to have_http_status(:ok)
        expect(data['list']).to be_nil
        expect(data['errors']).to include("Name can't be blank")
      end
    end

    it 'returns errors for name exceeding maximum length' do
      post '/graphql', params: { query: mutation, variables: { input: { id: list.id, name: "a" * 101 } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editList')

      aggregate_failures "validation errors" do
        expect(response).to have_http_status(:ok)
        expect(data['list']).to be_nil
        expect(data['errors']).to include("Name is too long (maximum is 100 characters)")
      end
    end
  end

  context 'with non-existent list' do
    it 'returns errors' do
      post '/graphql', params: { query: mutation, variables: { input: { id: 0 } } }, as: :json

      json = JSON.parse(response.body)
      data = json.dig('data', 'editList')

      aggregate_failures "not found errors" do
        expect(response).to have_http_status(:ok)
        expect(data['list']).to be_nil
        expect(data['errors']).to include("List not found")
      end
    end
  end
end
