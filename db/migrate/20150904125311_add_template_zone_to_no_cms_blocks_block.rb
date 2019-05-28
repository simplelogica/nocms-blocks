class AddTemplateZoneToNoCmsBlocksBlock < ActiveRecord::Migration
  def change
    add_column :no_cms_blocks_blocks, :template_zone, :string, index: true
  end
end
