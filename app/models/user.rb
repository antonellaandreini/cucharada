class User < ApplicationRecord
  has_secure_password

  has_many :recipes, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_recipes, through: :favorites, source: :recipe
  has_many :ratings, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :cook_photos, dependent: :destroy
  has_many :shopping_lists, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
end
