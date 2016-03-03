module NoCms::Blocks::Concerns
  module ModelWithSlots
    extend ActiveSupport::Concern

    self.included do
      has_many :block_slots, as: :container, class_name: 'NoCms::Blocks::BlockSlot', dependent: :destroy
      has_many :blocks, through: :block_slots

      accepts_nested_attributes_for :block_slots, allow_destroy: true

      ##
      # When duplicating a model with slots we should inform to the slots
      # whether they should duplicate the blocks or just link to the same
      # instances

      ##
      # This configuration is received in the model via an attr_accessor because
      # we can't modify the dup method signature, as it would be non-compatible
      # with the standard dup method from Ruby

      attr_accessor :dup_block_when_duping_slots

      ##
      # In the dup implementation we configure the `dup_block_when_duping_slot`
      # virtual attribute of the slot with the same value than the attribute
      # from this model. This way we propagate the configuration.
      def dup_with_slots options = {}
        duplicated = dup_without_slots
        # We just need to dub root slots, if there are nested slots
        # will be dupped in each slot
        block_slots.roots.each do |slot|
          slot.dup_block_when_duping_slot = dup_block_when_duping_slots
          duplicated.block_slots << slot.dup
        end
        duplicated
      end
      alias_method_chain :dup, :slots

    end

  end
end
