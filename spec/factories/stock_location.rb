FactoryBot.define do
  factory :stock_location, class: Spree::StockLocation do
    sequence(:name) { |n| "Location ##{n}" }
  end
end
