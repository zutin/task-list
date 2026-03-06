require 'rails_helper'

RSpec.describe 'GetBoards query', type: :request do
  let(:query) do
    <<~GQL
      query GetBoards {
        boards {
          id
          name
          description
          createdAt
          updatedAt
          lists {
            id
            name
            position
            tasks {
              id
              title
              position
            }
          }
        }
      }
    GQL
  end

  context 'when boards exist' do
    it 'returns all boards ordered by updated_at desc then name asc' do
      board_1 = create(:board, name: "Beta", updated_at: 1.day.ago)
      board_2 = create(:board, name: "Alpha", updated_at: Time.current)
      create(:list, name: "List 1", board: board_1, position: 1)

      post '/graphql', params: { query: query }

      json = JSON.parse(response.body)
      boards = json.dig('data', 'boards')

      aggregate_failures "boards with lists" do
        expect(response).to have_http_status(:ok)
        expect(boards.length).to eq(2)
        expect(boards.first['name']).to eq("Alpha")
        expect(boards.second['name']).to eq("Beta")
        expect(boards.second['lists'].length).to eq(1)
        expect(boards.second['lists'].first['name']).to eq("List 1")
      end
    end
  end

  context 'when no boards exist' do
    it 'returns an empty array' do
      post '/graphql', params: { query: query }

      json = JSON.parse(response.body)
      boards = json.dig('data', 'boards')

      expect(response).to have_http_status(:ok)
      expect(boards).to be_empty
    end
  end
end
