class CookPhoto < ApplicationRecord
  belongs_to :user
  belongs_to :recipe

  has_one_attached :image

  validates :caption, length: { maximum: 200 }
  validate :image_presence

  after_commit :convert_image_to_base64, on: [:create, :update]

  private

  def image_presence
    errors.add(:image, "es requerida") unless image.attached? || thumbnail_base64.present?
  end

  def convert_image_to_base64
    return unless image.attached?
    return if thumbnail_base64.present? && !image.blob.previously_new_record?

    blob = image.blob
    blob.open do |tempfile|
      pipeline = ImageProcessing::Vips
        .source(tempfile.path)
        .resize_to_limit(600, 600)
        .convert("jpeg")
        .saver(quality: 75)

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
