class AddNonTranslatedFieldsInfoToNoCmsBlocksBlock < ActiveRecord::Migration
  def change
    add_column :no_cms_blocks_blocks, :non_translated_fields_info, :longtext
  end
end
