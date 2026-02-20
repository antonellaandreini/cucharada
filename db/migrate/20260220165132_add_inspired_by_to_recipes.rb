class AddInspiredByToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :inspired_by, :string
  end
end
