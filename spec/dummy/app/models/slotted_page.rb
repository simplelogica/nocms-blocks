class SlottedPage < ActiveRecord::Base
  has_many :block_slots, as: :container, class_name: 'NoCms::Blocks::BlockSlot'
end
