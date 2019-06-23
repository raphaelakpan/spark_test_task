FactoryBot.define do
  factory :taxon, class: Spree::Taxon do
    sequence(:name) { |n| "Taxon ##{n}" }
  end
end
