FactoryGirl.define do
  factory :slotted_page do
    title { Faker::Lorem.sentence }
    skeleton 'default'
  end
end
