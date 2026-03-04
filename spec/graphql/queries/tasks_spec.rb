require 'rails_helper'

RSpec.describe 'GetTasks query', type: :request do
  let(:query) do
    <<~GQL
      query GetTasks($listIds: [ID!]) {
        tasks(listIds: $listIds) {
          id
          title
          description
          dueAt
          completed
          position
          createdAt
          updatedAt
        }
      }
    GQL
  end

  let(:list_1) { create(:list, :with_tasks, name: "Work") }
  let(:list_2) { create(:list, :with_tasks, name: "Personal", position: 2) }

  context 'without list_ids filter' do
    before { list_1; list_2 }

    it 'returns all tasks ordered by list_id and position' do
      post '/graphql', params: { query: query }

      json = JSON.parse(response.body)
      tasks = json.dig('data', 'tasks')

      aggregate_failures "all tasks" do
        expect(response).to have_http_status(:ok)
        expect(tasks.length).to eq(6)
        expect(tasks.map { |task| task['id'] }).to match_array((list_1.tasks + list_2.tasks).map { |task| task.id.to_s })
      end
    end
  end

  context 'with list_ids filter' do
    it 'returns only tasks from the specified lists' do
      post '/graphql', params: { query: query, variables: { listIds: [ list_1.id.to_s ] } }

      json = JSON.parse(response.body)
      tasks = json.dig('data', 'tasks')

      aggregate_failures "tasks from list_1" do
        expect(response).to have_http_status(:ok)
        expect(tasks.length).to eq(3)
        expect(tasks.map { |task| task['id'] }).to match_array(list_1.tasks.map { |task| task.id.to_s })
      end
    end

    it 'returns tasks from multiple lists' do
      post '/graphql', params: { query: query, variables: { listIds: [ list_1.id.to_s, list_2.id.to_s ] } }

      json = JSON.parse(response.body)
      tasks = json.dig('data', 'tasks')

      aggregate_failures "tasks from both lists" do
        expect(response).to have_http_status(:ok)
        expect(tasks.length).to eq(6)
        expect(tasks.map { |task| task['id'] }).to match_array((list_1.tasks + list_2.tasks).map { |task| task.id.to_s })
      end
    end

    it 'returns empty array when no tasks match the list_ids' do
      post '/graphql', params: { query: query, variables: { listIds: [ '99999' ] } }

      json = JSON.parse(response.body)
      tasks = json.dig('data', 'tasks')

      expect(response).to have_http_status(:ok)
      expect(tasks).to be_empty
    end
  end
end
