FactoryBot.define do
  factory :slotted_page do
    title { Faker::Lorem.sentence }
    template { 'default' }
  end
end
