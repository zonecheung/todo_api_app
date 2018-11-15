FactoryBot.define do
  factory :tag do
    sequence(:title) { |n| "Title #{n}" }
  end
end
