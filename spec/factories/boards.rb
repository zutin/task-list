FactoryBot.define do
  factory :board do
    name { "New board" }
    description { "Board description" }
  end

  trait :with_lists do
    after(:create) do |board|
      create_list(:list, 3, board: board)
    end
  end

  trait :with_lists_and_tasks do
    after(:create) do |board|
      create_list(:list, 3, :with_tasks, board: board)
    end
  end
end
