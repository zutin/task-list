require 'rails_helper'

RSpec.describe 'GetLists query', type: :request do
  let(:query) do
    <<~GQL
      query GetLists {
        lists {
          id
          name
          position
          createdAt
          updatedAt
          tasks {
            id
            title
            completed
            position
          }
        }
      }
    GQL
  end

  let(:list_1) { create(:list, :with_tasks, name: "Doing", position: 1) }
  let(:list_2) { create(:list, name: "Done", position: 2) }
  let(:tasks) { list_1.tasks }

  before { list_1; list_2 }

  context 'when lists exist' do
    it 'returns all lists ordered by position and their tasks' do
      post '/graphql', params: { query: query }

      json = JSON.parse(response.body)
      lists = json.dig('data', 'lists')

      aggregate_failures "lists with tasks" do
        expect(response).to have_http_status(:ok)
        expect(lists.length).to eq(2)
        expect(lists.first['name']).to eq("Doing")
        expect(lists.second['name']).to eq("Done")
        expect(lists.first['tasks'].length).to eq(3)
        expect(lists.first['tasks'].map { |t| t['title'] }).to match_array(tasks.map(&:title))
        expect(lists.second['tasks']).to be_empty
      end
    end
  end

  context 'when no lists exist' do
    before { List.destroy_all }

    it 'returns an empty array' do
      post '/graphql', params: { query: query }

      json = JSON.parse(response.body)
      lists = json.dig('data', 'lists')

      expect(response).to have_http_status(:ok)
      expect(lists).to be_empty
    end
  end
end
