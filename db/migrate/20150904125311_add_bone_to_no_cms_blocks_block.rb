class AddBoneToNoCmsBlocksBlock < ActiveRecord::Migration
  def change
    add_column :no_cms_blocks_blocks, :bone, :string
  end
end
