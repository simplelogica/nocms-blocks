class CreateNoCmsBlocksBlocks < ActiveRecord::Migration
  def change
    create_table :no_cms_blocks_blocks do |t|

      t.timestamps
    end

    NoCms::Blocks::Block.translated_attribute_names = [:layout, :fields_info, :draft]
    
    create_table :no_cms_blocks_block_translations do |t|
      t.string :layout
      t.text :fields_info, :limit => 4294967295
      t.boolean :draft
    end
  end
end
