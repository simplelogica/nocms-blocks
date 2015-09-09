module NoCms::Blocks
  class BlockSlot < ActiveRecord::Base

    acts_as_nested_set

    belongs_to :container, polymorphic: true
    belongs_to :block, class_name: "NoCms::Blocks::Block"

    accepts_nested_attributes_for :block

    scope :for_template_zone, -> (template_zone) { where(template_zone: template_zone) }

    validates :template_zone, presence: true

    def template_zone_config
      if container && container.class.include?(NoCms::Blocks::Concerns::ModelWithTemplate)
        container.template_config.zone(template_zone)
      end
    end

    validate :block_layout_belongs_to_template?

    ##
    # If the container has template restrictions we should take them into
    # account to check that the block layout is actually allowed in the current
    # template and zone
    def block_layout_belongs_to_template?
      if container && container.class.include?(NoCms::Blocks::Concerns::ModelWithTemplate)
        # If we change the zone, or the container changed the template, or the
        # block changed the layout, we check everything is alright
        if template_zone_changed? || container.template_changed? || block.layout_changed?
          unless template_zone_config.allowed_blocks.include?(block.layout.to_sym)
            errors.add(:template_zone, :invalid) if template_zone_changed?
          end
        end
      end
    end
    private :block_layout_belongs_to_template?


  end
end
