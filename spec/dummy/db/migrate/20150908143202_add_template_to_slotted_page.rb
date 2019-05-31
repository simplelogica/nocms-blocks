class AddTemplateToSlottedPage < NoCms::Blocks::Migration
  def change
    add_column :slotted_pages, :template, :string
  end
end
