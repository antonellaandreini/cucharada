class AddPerformanceIndexesToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_index :recipes, :source_type
    add_index :recipes, :visibility
    add_index :recipes, [:source_type, :created_at]
    add_index :recipes, [:visibility, :created_at]
    add_index :recipes, :user_id unless index_exists?(:recipes, :user_id)
  end
end
