FactoryBot.define do
  factory :shipping_category, class: Spree::ShippingCategory do
    sequence(:name) { |n| "Shipping ##{n}" }
  end
end
