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

    validate :validate_block_layout

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
    # know wether we should duplicate the block andasigning the new one or just
    # link the same instance
    def dup options = {}
      options.reverse_merge!({ dup_block: true })

      dupped = super()
      if options[:dup_block]
        dupped.block = block.dup
      end
      dupped
    end

  end
end
