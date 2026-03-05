require 'rails_helper'

RSpec.describe 'GetTasks query', type: :request do
  let(:query) do
    <<~GQL
      query GetTasks($listIds: [ID!], $completed: Boolean, $dueBefore: ISO8601DateTime, $dueAfter: ISO8601DateTime) {
        tasks(listIds: $listIds, completed: $completed, dueBefore: $dueBefore, dueAfter: $dueAfter) {
          id
          title
          description
          dueAt
          completedAt
          position
          createdAt
          updatedAt
        }
      }
    GQL
  end

  let(:list_1) { create(:list, :with_tasks, name: "Doing") }
  let(:list_2) { create(:list, :with_tasks, name: "Done", position: 2) }

  before { list_1; list_2 }

  context 'without list_ids filter' do
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

  context 'with completed filter' do
    let(:completed_task) { list_1.tasks.first }

    before { completed_task.update(completed_at: Time.current) }

    it 'returns only completed tasks' do
      post '/graphql', params: { query: query, variables: { completed: true } }.to_json, headers: { 'Content-Type': 'application/json' }

      json = JSON.parse(response.body)
      tasks = json.dig('data', 'tasks')

      aggregate_failures "completed tasks" do
        expect(response).to have_http_status(:ok)
        expect(tasks.length).to eq(1)
        expect(tasks.first['id']).to eq(list_1.tasks.first.id.to_s)
        expect(tasks.first['completedAt']).to eq(completed_task.completed_at.iso8601)
      end
    end

    it 'returns only incomplete tasks' do
      post '/graphql', params: { query: query, variables: { completed: false } }.to_json, headers: { 'Content-Type': 'application/json' }

      json = JSON.parse(response.body)
      tasks = json.dig('data', 'tasks')

      aggregate_failures "incomplete tasks" do
        expect(response).to have_http_status(:ok)
        expect(tasks.length).to eq(5)
        expect(tasks).to all(include('completedAt' => nil))
      end
    end
  end

  context 'with due_at filters' do
    let(:soon_task) { list_1.tasks.first }
    let(:later_task) { list_1.tasks.last }

    before do
      soon_task.update(due_at: 3.days.from_now)
      later_task.update(due_at: 10.days.from_now)
    end

    it 'returns tasks due before a given date' do
      post '/graphql', params: { query: query, variables: { dueBefore: 5.days.from_now.iso8601 } }

      json = JSON.parse(response.body)
      tasks = json.dig('data', 'tasks')

      aggregate_failures "due before" do
        expect(response).to have_http_status(:ok)
        expect(tasks.length).to eq(1)
        expect(tasks.first['id']).to eq(soon_task.id.to_s)
      end
    end

    it 'returns tasks due after a given date' do
      post '/graphql', params: { query: query, variables: { dueAfter: 5.days.from_now.iso8601 } }

      json = JSON.parse(response.body)
      tasks = json.dig('data', 'tasks')

      aggregate_failures "due after" do
        expect(response).to have_http_status(:ok)
        expect(tasks.length).to eq(1)
        expect(tasks.first['id']).to eq(later_task.id.to_s)
      end
    end

    it 'returns tasks within a date range' do
      post '/graphql', params: { query: query, variables: { dueAfter: 1.day.from_now.iso8601, dueBefore: 5.days.from_now.iso8601 } }

      json = JSON.parse(response.body)
      tasks = json.dig('data', 'tasks')

      aggregate_failures "date range" do
        expect(response).to have_http_status(:ok)
        expect(tasks.length).to eq(1)
        expect(tasks.first['id']).to eq(soon_task.id.to_s)
      end
    end
  end

  context 'with combined filters' do
    let(:completed_soon_task) { list_1.tasks.first }
    let(:pending_soon_task) { list_1.tasks.second }
    let(:completed_later_task) { list_1.tasks.third }

    before do
      completed_soon_task.update(completed_at: Time.current, due_at: 2.days.from_now)
      pending_soon_task.update(completed_at: nil, due_at: 2.days.from_now)
      completed_later_task.update(completed_at: Time.current, due_at: 10.days.from_now)
    end

    it 'filters by list, completed and due_before together' do
      post '/graphql', params: { query: query, variables: { listIds: [ list_1.id ], completed: true, dueBefore: 5.days.from_now.iso8601 } }.to_json, headers: { 'Content-Type': 'application/json' }

      json = JSON.parse(response.body)
      tasks = json.dig('data', 'tasks')

      aggregate_failures "combined filter" do
        expect(response).to have_http_status(:ok)
        expect(tasks.length).to eq(1)
        expect(tasks.first['id']).to eq(completed_soon_task.id.to_s)
      end
    end
  end
end
