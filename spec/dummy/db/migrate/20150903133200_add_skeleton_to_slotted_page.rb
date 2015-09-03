class AddSkeletonToSlottedPage < ActiveRecord::Migration
  def change
    add_column :slotted_pages, :skeleton, :string
  end
end
