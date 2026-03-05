require 'rails_helper'

RSpec.describe 'DeleteList mutation', type: :request do
  let(:mutation) do
    <<~GQL
      mutation DeleteList($input: DeleteListInput!) {
        deleteList(input: $input) {
          id
          errors
        }
      }
    GQL
  end

  context 'with valid id' do
    let!(:list) { create(:list, name: "To delete", position: 1) }

    it 'deletes the list and returns its id' do
      expect {
        post '/graphql', params: { query: mutation, variables: { input: { id: list.id } } }, as: :json
      }.to change(List, :count).by(-1)

      json = JSON.parse(response.body)
      data = json.dig('data', 'deleteList')

      aggregate_failures "deleted list" do
        expect(response).to have_http_status(:ok)
        expect(data['id']).to eq(list.id.to_s)
        expect(data['errors']).to be_empty
      end
    end
  end

  context 'with non-existent id' do
    it 'returns errors and nil id' do
      expect {
        post '/graphql', params: { query: mutation, variables: { input: { id: 0 } } }, as: :json
      }.not_to change(List, :count)

      json = JSON.parse(response.body)
      data = json.dig('data', 'deleteList')

      aggregate_failures "not found errors" do
        expect(response).to have_http_status(:ok)
        expect(data['id']).to be_nil
        expect(data['errors']).to include("List not found")
      end
    end
  end
end
