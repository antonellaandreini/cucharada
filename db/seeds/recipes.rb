# db/seeds/recipes.rb
# Crea usuario Cucharada e importa recetas curadas desde JSON

RECIPES_JSON = Rails.root.join("db/seeds/recipes_data.json")

unless File.exist?(RECIPES_JSON)
  puts "No se encontro #{RECIPES_JSON}. Ejecuta 'rails generate_recipes' primero."
  return
end

puts "Creating Cucharada user..."
cucharada_user = User.find_or_create_by!(email: "cucharada@cucharada.app") do |u|
  u.name = "Cucharada"
  u.password = SecureRandom.hex(32)
end
puts "  User: #{cucharada_user.email} (id: #{cucharada_user.id})"

puts "Loading recipes from JSON..."
recipes_data = JSON.parse(File.read(RECIPES_JSON))
puts "  Found #{recipes_data.size} recipes in JSON"

# Pre-cargar ingredientes para búsqueda rápida
ingredient_map = {}
Ingredient.find_each do |ing|
  ingredient_map[ing.name.downcase.strip] = ing
  # También indexar aliases
  if ing.aliases.present?
    ing.aliases.split(",").each do |a|
      ingredient_map[a.strip.downcase] = ing
    end
  end
end
puts "  #{ingredient_map.size} ingredient entries indexed"

imported = 0
skipped = 0
warnings = []

recipes_data.each_with_index do |data, index|
  title = data["title"]&.strip
  chef_name = data["chef_name"]&.strip

  unless title.present?
    skipped += 1
    next
  end

  # Idempotencia: skip si ya existe
  if Recipe.exists?(title: title, chef_name: chef_name, user: cucharada_user)
    skipped += 1
    next
  end

  recipe = Recipe.new(
    user: cucharada_user,
    title: title,
    description: data["description"],
    chef_name: chef_name,
    prep_time: data["prep_time"],
    cook_time: data["cook_time"],
    servings: data["servings"],
    source_type: "cucharada",
    visibility: "public"
  )

  # Ingredientes
  if data["ingredients"].is_a?(Array)
    data["ingredients"].each do |ing_data|
      name = ing_data["name"]&.strip&.downcase
      ingredient = ingredient_map[name]

      unless ingredient
        warnings << "Ingrediente no encontrado: '#{ing_data["name"]}' (receta: #{title})"
        next
      end

      recipe.recipe_ingredients.build(
        ingredient: ingredient,
        quantity: ing_data["quantity"],
        unit: ing_data["unit"],
        notes: ing_data["notes"]
      )
    end
  end

  # Pasos
  if data["steps"].is_a?(Array)
    data["steps"].each_with_index do |step, step_idx|
      instruction = step.is_a?(String) ? step : step["instruction"]
      next unless instruction.present?

      recipe.recipe_steps.build(
        step_number: step_idx + 1,
        instruction: instruction
      )
    end
  end

  if recipe.save
    imported += 1
  else
    warnings << "Error guardando '#{title}': #{recipe.errors.full_messages.join(', ')}"
    skipped += 1
  end

  if (index + 1) % 100 == 0
    print "\r  Progreso: #{index + 1}/#{recipes_data.size} (importadas: #{imported}, skipped: #{skipped})"
  end
end

puts "\n  Importación completada: #{imported} importadas, #{skipped} skipped"

if warnings.any?
  puts "\n  Warnings (#{warnings.size}):"
  warnings.first(20).each { |w| puts "    - #{w}" }
  puts "    ... y #{warnings.size - 20} más" if warnings.size > 20
end
