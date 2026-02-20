class AddVisibilityToRecipes < ActiveRecord::Migration[8.1]
  def up
    add_column :recipes, :visibility, :string, default: "private", null: false

    # Curated recipes should be public
    Recipe.where(source_type: "cucharada").update_all(visibility: "public")
  end

  def down
    remove_column :recipes, :visibility
  end
end
