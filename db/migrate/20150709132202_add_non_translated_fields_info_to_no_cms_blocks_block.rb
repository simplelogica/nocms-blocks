class AddNonTranslatedFieldsInfoToNoCmsBlocksBlock < ActiveRecord::Migration
  def change
    if NoCms::Blocks.installed_db_gem == 'pg'
      if NoCms::Blocks.database_serializer.to_s == "hstore"
        add_column :no_cms_blocks_blocks, :fields_info, :hstore
      else
        add_column :no_cms_blocks_blocks, :fields_info, :text
      end
    else
      add_column :no_cms_blocks_blocks, :fields_info, :longtext
    end
  end
end
