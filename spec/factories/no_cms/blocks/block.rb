# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :block, class: NoCms::Blocks::Block do
    layout { 'general1' }
    draft { false }

  end
end
