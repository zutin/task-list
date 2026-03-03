FactoryBot.define do
  factory :list do
    name { "New list" }
    position { 1 }

    trait :with_tasks do
      after(:create) do |list|
        create_list(:task, 3, list: list)
      end
    end
  end
end
