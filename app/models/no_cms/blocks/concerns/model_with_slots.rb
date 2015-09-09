module NoCms::Blocks::Concerns
  module ModelWithSlots
    extend ActiveSupport::Concern

    self.included do
      has_many :block_slots, as: :container, class_name: 'NoCms::Blocks::BlockSlot'
      has_many :blocks, through: :block_slots

      accepts_nested_attributes_for :block_slots, allow_destroy: true

    end

  end
end
