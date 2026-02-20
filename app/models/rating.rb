class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  validates :score, presence: true, inclusion: { in: 1..5 }
  validates :recipe_id, uniqueness: { scope: :user_id, message: "ya fue calificada" }
  validate :cannot_rate_own_recipe

  private

  def cannot_rate_own_recipe
    errors.add(:base, "No podés calificar tu propia receta") if recipe&.user_id == user_id
  end
end
