class AddTemplateToSlottedPage < ActiveRecord::Migration
  def change
    add_column :slotted_pages, :template, :string
  end
end
