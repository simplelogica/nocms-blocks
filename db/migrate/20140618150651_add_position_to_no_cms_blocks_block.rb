class AddPositionToNoCmsBlocksBlock < NoCms::Blocks::Migration
  def change
    add_column :no_cms_blocks_blocks, :position, :integer
  end
end
