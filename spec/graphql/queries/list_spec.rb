require 'rails_helper'

RSpec.describe 'GetList query', type: :request do
  let(:query) do
    <<~GQL
      query GetList($id: ID!) {
        list(id: $id) {
          id
          name
          position
          createdAt
          updatedAt
        }
      }
    GQL
  end

  let(:list) { create(:list, name: "My list") }

  it 'returns the list by ID' do
    post '/graphql', params: { query: query, variables: { id: list.id.to_s } }

    json = JSON.parse(response.body)
    data = json.dig('data', 'list')

    aggregate_failures "list data" do
      expect(response).to have_http_status(:ok)
      expect(data['id']).to eq(list.id.to_s)
      expect(data['name']).to eq("My list")
      expect(data['position']).to eq(1)
    end
  end

  it 'returns nil when the list is not found' do
    post '/graphql', params: { query: query, variables: { id: "999999" } }

    json = JSON.parse(response.body)

    expect(response).to have_http_status(:ok)
    expect(json.dig('data', 'list')).to be_nil
  end
end
