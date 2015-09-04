module NoCms::Blocks
  class BlockSlot < ActiveRecord::Base

    acts_as_nested_set

    belongs_to :container, polymorphic: true
    belongs_to :block, class_name: "NoCms::Blocks::Block"

    accepts_nested_attributes_for :block

    scope :for_bone, -> (bone) { where(bone: bone) }

    validates :bone, presence: true


  end
end
