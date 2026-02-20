class AddThumbnailBase64ToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :thumbnail_base64, :text
  end
end
