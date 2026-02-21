class Recipe < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :full_text_search,
    using: {
      tsearch: {
        tsvector_column: "search_vector",
        dictionary: "spanish",
        prefix: true
      }
    }

  belongs_to :user

  has_many :recipe_ingredients, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients
  has_many :recipe_steps, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :recipe_tags, dependent: :destroy
  has_many :tags, through: :recipe_tags
  has_many :cook_photos, dependent: :destroy

  has_one_attached :image

  after_commit :convert_image_to_base64, on: [:create, :update]

  validates :title, presence: true

  scope :publicly_visible, -> { where(visibility: "public") }
  scope :without_base64, -> { select(column_names - ["thumbnail_base64"]) }

  def public?
    visibility == "public"
  end

  def private?
    visibility == "private"
  end

  accepts_nested_attributes_for :recipe_ingredients, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :recipe_steps, allow_destroy: true, reject_if: :all_blank

  def favorited_by?(user)
    return false unless user
    favorites.exists?(user: user)
  end

  def average_rating
    if ratings.loaded?
      return nil if ratings.empty?
      (ratings.sum(&:score).to_f / ratings.size).round(1)
    else
      ratings.average(:score)&.round(1)
    end
  end

  def rating_by(user)
    return nil unless user
    ratings.find_by(user: user)
  end

  private

  def convert_image_to_base64
    return unless image.attached?
    return if thumbnail_base64.present? && !image.blob.previously_new_record?

    blob = image.blob
    blob.open do |tempfile|
      pipeline = ImageProcessing::Vips
        .source(tempfile.path)
        .resize_to_limit(800, 800)
        .convert("jpeg")
        .saver(quality: 80)

      result = pipeline.call
      jpeg_data = File.read(result.path, mode: "rb")
      encoded = Base64.strict_encode64(jpeg_data)
      update_column(:thumbnail_base64, "data:image/jpeg;base64,#{encoded}")
      result.close
      File.delete(result.path) if File.exist?(result.path)
    end

    image.purge_later
  end
end
