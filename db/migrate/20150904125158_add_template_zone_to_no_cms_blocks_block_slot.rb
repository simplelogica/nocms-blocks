class AddTemplateZoneToNoCmsBlocksBlockSlot < NoCms::Blocks::Migration
  def change
    add_column :no_cms_blocks_block_slots, :template_zone, :string, index: true
  end
end
