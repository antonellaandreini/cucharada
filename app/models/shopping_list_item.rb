class ShoppingListItem < ApplicationRecord
  belongs_to :shopping_list
  belongs_to :ingredient
  belongs_to :recipe, optional: true

  scope :checked, -> { where(checked: true) }
  scope :unchecked, -> { where(checked: false) }
end
