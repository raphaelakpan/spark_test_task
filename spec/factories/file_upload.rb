FactoryBot.define do
  factory :file_upload do
    sequence(:file_name) { |n| "File ##{n}" }
    file_type { "text/csv" }
    creator factory: :user
  end
end
