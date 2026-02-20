class RecipeParserService
  def initialize(user)
    @user = user
    @gemini = GeminiService.new
  end

  # Process an uploaded image and create a recipe
  def from_image(image_blob)
    image_data = image_blob.download
    mime_type = image_blob.content_type

    data = @gemini.extract_from_image(image_data, mime_type)
    build_recipe(data, source_type: "photo")
  end

  # Process a URL and create a recipe
  def from_url(url)
    scraper = UrlScraperService.new(url)
    text = scraper.scrape

    raise "No se pudo extraer contenido de la URL" if text.blank?

    data = @gemini.extract_from_text(text)
    build_recipe(data, source_type: "link", source_url: url)
  end

  private

  def build_recipe(data, source_type:, source_url: nil)
    recipe = @user.recipes.new(
      title: data["title"] || "Receta sin título",
      description: data["description"],
      source_type: source_type,
      source_url: source_url,
      servings: data["servings"],
      prep_time: data["prep_time"],
      cook_time: data["cook_time"]
    )

    # Add ingredients
    if data["ingredients"].is_a?(Array)
      data["ingredients"].each do |ing_data|
        ingredient = match_ingredient(ing_data["name"])
        recipe.recipe_ingredients.build(
          ingredient: ingredient,
          quantity: ing_data["quantity"],
          unit: ing_data["unit"],
          notes: ing_data["notes"]
        )
      end
    end

    # Add steps
    if data["steps"].is_a?(Array)
      data["steps"].each_with_index do |step_data, index|
        recipe.recipe_steps.build(
          step_number: step_data["step_number"] || (index + 1),
          instruction: step_data["instruction"]
        )
      end
    end

    recipe.save!
    recipe
  end

  # Find ingredient in DB or create if not found
  def match_ingredient(name)
    return Ingredient.find_or_create_by!(name: "Ingrediente desconocido", category: "Otros") if name.blank?

    normalized = name.strip.downcase

    # Exact match
    ingredient = Ingredient.where("LOWER(name) = ?", normalized).first

    # Search in aliases
    ingredient ||= Ingredient.where("aliases ILIKE ?", "%#{normalized}%").first

    # Partial match
    ingredient ||= Ingredient.where("name ILIKE ?", "%#{normalized}%").first

    # Create new if not found
    ingredient || Ingredient.create!(name: name.strip.titleize, category: "Otros")
  end
end
