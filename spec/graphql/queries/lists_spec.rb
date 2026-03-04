require 'rails_helper'

RSpec.describe 'GetLists query', type: :request do
  let(:query) do
    <<~GQL
      query GetLists($includeTasks: Boolean) {
        lists(includeTasks: $includeTasks) {
          id
          name
          position
          createdAt
          updatedAt
        }
      }
    GQL
  end

  let(:query_with_tasks) do
    <<~GQL
      query GetLists($includeTasks: Boolean) {
        lists(includeTasks: $includeTasks) {
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

  let(:list_1) { create(:list, name: "Doing", position: 1) }
  let(:list_2) { create(:list, name: "Done", position: 2) }

  before { list_1; list_2 }

  context 'without include_tasks' do
    it 'returns all lists ordered by position' do
      post '/graphql', params: { query: query }

      json = JSON.parse(response.body)
      lists = json.dig('data', 'lists')

      aggregate_failures "all lists" do
        expect(response).to have_http_status(:ok)
        expect(lists.length).to eq(2)
        expect(lists.first['name']).to eq("Doing")
        expect(lists.second['name']).to eq("Done")
      end
    end
  end

  context 'with include_tasks' do
    let(:tasks) { create_list(:task, 2, list: list_1) }

    before { tasks }

    it 'returns lists with their tasks' do
      post '/graphql', params: { query: query_with_tasks, variables: { includeTasks: true } }.to_json, headers: { 'Content-Type': 'application/json' }

      json = JSON.parse(response.body)
      lists = json.dig('data', 'lists')

      aggregate_failures "lists with tasks" do
        expect(response).to have_http_status(:ok)
        expect(lists.length).to eq(2)
        expect(lists.first['tasks'].length).to eq(2)
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
