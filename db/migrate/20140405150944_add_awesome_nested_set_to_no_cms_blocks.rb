class AddAwesomeNestedSetToNoCmsBlocks < NoCms::Blocks::Migration
  def change
    add_reference :no_cms_blocks_blocks, :parent, index: true
    add_column :no_cms_blocks_blocks, :lft, :integer
    add_column :no_cms_blocks_blocks, :rgt, :integer
    add_column :no_cms_blocks_blocks, :depth, :integer
  end
end
