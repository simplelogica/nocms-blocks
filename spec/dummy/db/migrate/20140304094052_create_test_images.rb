class CreateTestImages < ActiveRecord::Migration
  def change
    create_table :test_images do |t|
      t.string :logo
      t.string :name
      t.timestamps
    end
  end
end
