class CreateNoCmsBlocksBlockSlots < ActiveRecord::Migration
  def change
    create_table :no_cms_blocks_block_slots do |t|
      t.belongs_to :container, polymorphic: true, index: {name: 'index_no_cms_blocks_block_slots_on_container_type_and_id'}
      t.belongs_to :no_cms_blocks_block, index: true, foreign_key: true
      t.integer :position, default: 0

      t.timestamps null: false
    end
  end
end
