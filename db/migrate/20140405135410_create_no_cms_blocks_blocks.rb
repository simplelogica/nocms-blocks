# This migration comes from no_cms_blocks (originally 20140405135410)
class CreateNoCmsBlocksBlocks < NoCms::Blocks::Migration
  def change

    if NoCms::Blocks.database_serializer.to_s == "hstore"
      enable_extension 'hstore'
    end

    create_table :no_cms_blocks_blocks do |t|
      t.timestamps
    end

    NoCms::Blocks::Block.translated_attribute_names = [:locale, :layout, :fields_info, :draft]

    create_table :no_cms_blocks_block_translations do |t|
      t.belongs_to :no_cms_blocks_block, index: { name: 'no_cms_blocks_blocks_translations_block_id' }
      t.string :locale
      t.string :layout
      if NoCms::Blocks.installed_db_gem == 'pg'
        if NoCms::Blocks.database_serializer.to_s == "hstore"
          t.hstore :fields_info
        else
          t.text :fields_info
        end
      else
        t.text :fields_info, :limit => 4294967295
      end
      t.boolean :draft
    end
  end
end
