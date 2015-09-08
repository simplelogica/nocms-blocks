module NoCms::Blocks
  class BlockSlot < ActiveRecord::Base

    acts_as_nested_set

    belongs_to :container, polymorphic: true
    belongs_to :block, class_name: "NoCms::Blocks::Block"

    accepts_nested_attributes_for :block

    scope :for_template_zone, -> (template_zone) { where(template_zone: template_zone) }

    validates :template_zone, presence: true

    def template_zone_config
      container.template_config.zone(template_zone)
    end

  end
end
