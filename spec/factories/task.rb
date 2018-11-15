FactoryBot.define do
  factory :task do
    sequence(:title) { |n| "Title #{n}" }
  end
end
