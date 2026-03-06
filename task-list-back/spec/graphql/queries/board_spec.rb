require 'rails_helper'

RSpec.describe 'GetBoard query', type: :request do
  let(:query) do
    <<~GQL
      query GetBoard($id: ID!) {
        board(id: $id) {
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

  let(:board) { create(:board, name: "My board", description: "A description") }

  it 'returns the board by ID with lists and tasks' do
    list = create(:list, name: "To do", board: board, position: 1)
    create(:task, title: "Task 1", list: list, position: 1)

    post '/graphql', params: { query: query, variables: { id: board.id.to_s } }

    json = JSON.parse(response.body)
    data = json.dig('data', 'board')

    aggregate_failures "board data" do
      expect(response).to have_http_status(:ok)
      expect(data['id']).to eq(board.id.to_s)
      expect(data['name']).to eq("My board")
      expect(data['description']).to eq("A description")
      expect(data['lists'].length).to eq(1)
      expect(data['lists'].first['name']).to eq("To do")
      expect(data['lists'].first['tasks'].length).to eq(1)
      expect(data['lists'].first['tasks'].first['title']).to eq("Task 1")
    end
  end

  it 'returns nil when the board is not found' do
    post '/graphql', params: { query: query, variables: { id: "999999" } }

    json = JSON.parse(response.body)

    expect(response).to have_http_status(:ok)
    expect(json.dig('data', 'board')).to be_nil
  end
end
