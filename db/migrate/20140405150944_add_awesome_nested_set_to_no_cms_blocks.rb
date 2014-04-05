class AddAwesomeNestedSetToNoCmsBlocks < ActiveRecord::Migration
  def change
    add_column :no_cms_blocks_blocks, :parent_id, :integer
    add_column :no_cms_blocks_blocks, :lft, :integer
    add_column :no_cms_blocks_blocks, :rgt, :integer
    add_column :no_cms_blocks_blocks, :depth, :integer
  end
end
