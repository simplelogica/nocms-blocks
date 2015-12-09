class AddNonTranslatedFieldsInfoToNoCmsBlocksBlock < ActiveRecord::Migration
  def change
    if NoCms::Blocks.installed_db_gem == 'pg'
      add_column :no_cms_blocks_blocks, :fields_info, :text
    else
      add_column :no_cms_blocks_blocks, :fields_info, :longtext
    end
  end
end
