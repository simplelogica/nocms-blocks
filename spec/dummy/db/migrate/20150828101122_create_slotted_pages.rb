class CreateSlottedPages < ActiveRecord::Migration
  def change
    create_table :slotted_pages do |t|
      t.string :title

      t.timestamps null: false
    end
  end
end
