FactoryBot.define do
  factory :board do
    name { "MyString" }
    description { "MyString" }
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
