class AddNonTranslatedFieldsInfoToNoCmsBlocksBlock < ActiveRecord::Migration
  def change
    add_column :no_cms_blocks_blocks, :fields_info, :longtext
  end
end
