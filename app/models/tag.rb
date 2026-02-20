class Tag < ApplicationRecord
  has_many :recipe_tags, dependent: :destroy
  has_many :recipes, through: :recipe_tags

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug

  scope :popular, -> { left_joins(:recipe_tags).group(:id).order("COUNT(recipe_tags.id) DESC") }

  private

  def generate_slug
    self.slug = name&.parameterize if slug.blank? || name_changed?
  end
end
