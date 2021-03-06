# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :block_slot, class: NoCms::Blocks::BlockSlot do
    block { create :block }
    template_zone 'header'
    container { create :slotted_page }

    factory :block_slot_without_contaier do
      container { nil }
    end
  end
end
