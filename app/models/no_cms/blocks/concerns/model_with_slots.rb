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
        options.reverse_merge!({ dup_blocks: true })

        duplicated = dup_without_slots

        slot_dups = {}
        # Order by depth to avoid between children and parents dups
        slots = block_slots.order(:depth)
        slots.each do |slot|
          slot.dup_block_when_duping_slot = dup_block_when_duping_slots
          slot_dups[slot] = slot.dup
        end

        # Resolve relations
        slots.each do |slot|
          slot_dup = slot_dups[slot]
          slot_dup.container = duplicated
          slot_parent = slot_dups[slot.parent]
          if slot_parent
            slot_dup.parent = slot_parent
            slot_parent.children << slot_dup
          end
        end

        slot_dups.each do |_, slot_dup|
          duplicated.block_slots << slot_dup
        end

        duplicated
      end
      alias_method_chain :dup, :slots

    end

  end
end
