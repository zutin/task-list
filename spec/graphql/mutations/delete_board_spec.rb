require 'rails_helper'

RSpec.describe 'DeleteBoard mutation', type: :request do
  let(:mutation) do
    <<~GQL
      mutation DeleteBoard($input: DeleteBoardInput!) {
        deleteBoard(input: $input) {
          id
          errors
        }
      }
    GQL
  end

  context 'with valid id' do
    let(:board) { create(:board, name: "To delete") }

    before { board }

    it 'deletes the board and returns its id' do
      expect {
        post '/graphql', params: { query: mutation, variables: { input: { id: board.id } } }, as: :json
      }.to change(Board, :count).by(-1)

      json = JSON.parse(response.body)
      data = json.dig('data', 'deleteBoard')

      aggregate_failures "deleted board" do
        expect(response).to have_http_status(:ok)
        expect(data['id']).to eq(board.id.to_s)
        expect(data['errors']).to be_empty
      end
    end
  end

  context 'with non-existent id' do
    it 'returns errors and nil id' do
      expect {
        post '/graphql', params: { query: mutation, variables: { input: { id: 0 } } }, as: :json
      }.not_to change(Board, :count)

      json = JSON.parse(response.body)
      data = json.dig('data', 'deleteBoard')

      aggregate_failures "not found errors" do
        expect(response).to have_http_status(:ok)
        expect(data['id']).to be_nil
        expect(data['errors']).to include("Board not found")
      end
    end
  end
end
