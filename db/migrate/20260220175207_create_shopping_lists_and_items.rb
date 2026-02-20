class CreateShoppingListsAndItems < ActiveRecord::Migration[8.1]
  def change
    create_table :shopping_lists do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.timestamps
    end

    create_table :shopping_list_items do |t|
      t.references :shopping_list, null: false, foreign_key: true
      t.references :ingredient, null: false, foreign_key: true
      t.references :recipe, foreign_key: true
      t.string :quantity
      t.string :unit
      t.boolean :checked, default: false, null: false
      t.timestamps
    end
    add_index :shopping_list_items, [:shopping_list_id, :ingredient_id]
  end
end
