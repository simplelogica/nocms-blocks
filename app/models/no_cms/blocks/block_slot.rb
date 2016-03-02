module NoCms::Blocks
  class BlockSlot < ActiveRecord::Base

    acts_as_nested_set scope: [:container_type, :container_id]

    belongs_to :container, polymorphic: true
    belongs_to :block, class_name: "NoCms::Blocks::Block"

    accepts_nested_attributes_for :block
    accepts_nested_attributes_for :children, allow_destroy: true

    scope :for_template_zone, -> (template_zone) { where(template_zone: template_zone) }

    # The awesome nested set has a scope on container, so we need to validate the presence
    validates :template_zone, :container, presence: true

    def template_zone_config
      if container && container.class.include?(NoCms::Blocks::Concerns::ModelWithTemplate)
        container.template_config.zone(template_zone)
      end
    end

    validate :validate_block_layout

    before_validation :ensure_container

    def ensure_container
      self.container = parent.container if container.blank? && parent
    end

    ##
    # If the container has template restrictions we should take them into
    # account to check that the block layout is actually allowed in the current
    # template and zone
    def validate_block_layout
      if container && container.class.include?(NoCms::Blocks::Concerns::ModelWithTemplate)
        # If we change the zone, or the container changed the template, or the
        # block changed the layout, we check everything is alright
        if template_zone_changed?
          unless block_layout_belongs_to_template?
            errors.add(:template_zone, :invalid)
          end
        end
      end
    end
    private :validate_block_layout

    ##
    # This method checks that the block layout is valid in the context of the
    # contaienr template and the slot zone (if they have restrictions)
    def block_layout_belongs_to_template?
      if template_zone_config
        template_zone_config.allowed_layouts.map(&:to_s).include?(block.layout.to_s)
      else
        # If there's no template configuration that means we have no
        # restrictions and must return true always
        true
      end
    end

    ##
    # When duplicating a block slot we receive a configuration that allows us to
    # know wether we should duplicate the block and asigning the new one or just
    # link the same instance

    ##
    # This configuration is received via an attr_accessor because we can't
    # modify the dup method signature, as it would be non-compatible with the
    # standard dup method from Ruby

    attr_accessor :dup_block_when_duping_slot

    ##
    # In the dup implementation we check for the value of the
    # `dup_block_when_duping_slot` virtual attribute and then dup the block
    # instead of linking to the same instance.
    def dup
      dupped = super
      (dupped.block = block.dup) if dup_block_when_duping_slot
      dupped
    end

  end
end
