class AddBoneToNoCmsBlocksBlockSlot < ActiveRecord::Migration
  def change
    add_column :no_cms_blocks_block_slots, :bone, :string
  end
end
