FactoryBot.define do
  factory :role, class: Spree::Role do
    sequence(:name) { |n| "Role ##{n}" }

    trait :admin do
      name { "admin" }
    end
  end
end
