FactoryBot.define do
  factory :product, class: Spree::Product do
    sequence(:name) { |n| "Product ##{n}" }
    price  { Faker::Number.decimal(2).to_f }
    shipping_category

    trait :in_stock do
      after :create do |product|
        product.master.stock_items.first.adjust_count_on_hand(10)
      end
    end

    before :create do
      create(:stock_location) unless Spree::StockLocation.exists?
    end
  end
end
