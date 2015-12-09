# This migration comes from no_cms_blocks (originally 20140405135410)
class CreateNoCmsBlocksBlocks < ActiveRecord::Migration
  def change
    create_table :no_cms_blocks_blocks do |t|

      t.timestamps
    end

    NoCms::Blocks::Block.translated_attribute_names = [:locale, :layout, :fields_info, :draft]

    create_table :no_cms_blocks_block_translations do |t|
      t.belongs_to :no_cms_blocks_block
      t.string :locale
      t.string :layout
      if NoCms::Blocks.installed_db_gem == 'pg'
        t.text :fields_info
      else
        t.text :fields_info, :limit => 4294967295
      end
      t.boolean :draft
    end

    add_index :no_cms_blocks_block_translations, :no_cms_blocks_block_id,  { name: 'no_cms_blocks_blocks_translations_block_id'}
  end
end
