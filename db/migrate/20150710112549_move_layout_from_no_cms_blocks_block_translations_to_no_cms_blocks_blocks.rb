class MoveLayoutFromNoCmsBlocksBlockTranslationsToNoCmsBlocksBlocks < ActiveRecord::Migration
  def up
    add_column :no_cms_blocks_blocks, :layout, :string

    NoCms::Blocks::Block::Translation.all.each do |translation|
      translation.globalized_model.update_column layout: translation.layout
    end

    remove_column :no_cms_blocks_block_translations, :layout, :string
  end

  def down
    add_column :no_cms_blocks_block_translations, :layout, :string
    NoCms::Blocks::Block::Translation.all.each do |translation|
      translation.update_column layout: translation.globalized_model.layout
    end
    remove_column :no_cms_blocks_blocks, :layout, :string
  end
end
