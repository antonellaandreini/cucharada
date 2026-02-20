class ShoppingList < ApplicationRecord
  belongs_to :user
  has_many :items, class_name: "ShoppingListItem", dependent: :destroy

  def display_name
    name.presence || "Lista del #{created_at.strftime('%-d/%m/%Y')}"
  end

  def add_recipe_ingredients(recipe)
    recipe.recipe_ingredients.includes(:ingredient).each do |ri|
      existing = items.find_by(ingredient: ri.ingredient, unit: ri.unit)

      if existing
        existing.update(quantity: merge_quantities(existing.quantity, ri.quantity))
      else
        items.create!(
          ingredient: ri.ingredient,
          recipe: recipe,
          quantity: ri.quantity,
          unit: ri.unit
        )
      end
    end
  end

  private

  def merge_quantities(current, added)
    current_num = current.to_f
    added_num = added.to_f

    if current_num > 0 && added_num > 0
      (current_num + added_num).to_s
    else
      [current, added].compact.join(" + ")
    end
  end
end
