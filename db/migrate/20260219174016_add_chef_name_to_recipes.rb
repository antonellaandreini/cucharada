class AddChefNameToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :chef_name, :string
  end
end
