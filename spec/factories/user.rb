FactoryBot.define do
  factory :user, class: Spree::User do
    email { Faker::Internet.email }
    login { email }
    password { "abcdef123456" }
    password_confirmation { password }

    trait :admin do
      spree_roles { [Spree::Role.find_by(name: "admin") || create(:role, :admin)] }
    end
  end
end
