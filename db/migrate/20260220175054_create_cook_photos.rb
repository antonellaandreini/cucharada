class CreateCookPhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :cook_photos do |t|
      t.references :user, null: false, foreign_key: true
      t.references :recipe, null: false, foreign_key: true
      t.string :caption
      t.text :thumbnail_base64
      t.timestamps
    end
    add_index :cook_photos, [:recipe_id, :created_at]
  end
end
