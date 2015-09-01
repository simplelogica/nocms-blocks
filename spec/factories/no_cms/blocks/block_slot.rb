# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :block_slot, class: NoCms::Blocks::BlockSlot do
    block { FactoryGirl.create :block }
  end
end
