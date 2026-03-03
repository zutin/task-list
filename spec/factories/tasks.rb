FactoryBot.define do
  factory :task do
    title { "New task" }
    position { 1 }
    association :list
  end
end
