class RecipeStep < ApplicationRecord
  belongs_to :recipe

  validates :step_number, presence: true
  validates :instruction, presence: true

  default_scope { order(:step_number) }
end
