class Ingredient < ApplicationRecord
  has_many :recipe_ingredients, dependent: :destroy
  has_many :recipes, through: :recipe_ingredients

  validates :name, presence: true, uniqueness: true

  scope :search_by_name, ->(query) {
    where("name ILIKE ?", "%#{query}%")
  }
end
