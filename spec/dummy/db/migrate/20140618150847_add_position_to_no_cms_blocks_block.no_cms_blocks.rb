# This migration comes from no_cms_blocks (originally 20140618150651)
class AddPositionToNoCmsBlocksBlock < ActiveRecord::Migration
  def change
    add_column :no_cms_blocks_blocks, :position, :integer
  end
end
