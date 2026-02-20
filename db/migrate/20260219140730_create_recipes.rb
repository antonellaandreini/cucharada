class CreateRecipes < ActiveRecord::Migration[8.1]
  def change
    create_table :recipes do |t|
      t.string :title
      t.text :description
      t.string :source_url
      t.string :source_type
      t.integer :servings
      t.integer :prep_time
      t.integer :cook_time
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
