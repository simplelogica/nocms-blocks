module NoCms::Blocks
  class Blocks::BlockSlot < ActiveRecord::Base
    belongs_to :container, polymorphic: true
    belongs_to :no_cms_blocks_block
  end
end
