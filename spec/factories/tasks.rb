FactoryBot.define do
  factory :task do
    title { "New task" }
    position { 1 }
    association :list

    trait :completed do
      completed { true }
    end

    trait :with_due_date do
      due_at { 3.days.from_now }
    end
  end
end
