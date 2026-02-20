puts "Seeding tags..."

TAG_NAMES = %w[
  Asado Pastas Sopas Ensaladas Postres Panadería Empanadas Tartas
  Vegano Vegetariano Rápido Dulce Salado Carnes Pescados Mariscos
  Bebidas Salsas Desayuno Navideño Sin\ TACC Picada Arroces Guisos
].freeze

TAG_NAMES.each do |name|
  Tag.find_or_create_by!(name: name)
end

puts "  #{Tag.count} tags created."

# Auto-tag curated recipes by keyword matching
TAG_KEYWORDS = {
  "Asado" => %w[asado parrilla brasa grilla],
  "Pastas" => %w[pasta fideos ravioles ñoquis lasaña sorrentinos tallarines espagueti canelones],
  "Sopas" => %w[sopa caldo crema\ de],
  "Ensaladas" => %w[ensalada],
  "Postres" => %w[postre torta brownie flan mousse helado budín tiramisú cheesecake dulce\ de alfajor],
  "Panadería" => %w[pan focaccia brioche],
  "Empanadas" => %w[empanada],
  "Tartas" => %w[tarta quiche],
  "Vegano" => %w[vegano vegana],
  "Vegetariano" => %w[vegetariano vegetariana],
  "Dulce" => %w[dulce mermelada jalea miel chocolate],
  "Salado" => %w[salado],
  "Carnes" => %w[carne bife lomo costilla pollo milanesa bondiola cerdo cordero],
  "Pescados" => %w[pescado salmón merluza trucha atún],
  "Mariscos" => %w[marisco camarón langostino calamar pulpo],
  "Bebidas" => %w[bebida licuado smoothie],
  "Salsas" => %w[salsa chimichurri],
  "Desayuno" => %w[desayuno tostada granola panqueque],
  "Navideño" => %w[navideño navidad vitel],
  "Sin TACC" => %w[sin\ tacc celíaco],
  "Picada" => %w[picada tabla],
  "Arroces" => %w[arroz risotto paella],
  "Guisos" => %w[guiso locro estofado carbonada]
}.freeze

puts "Auto-tagging curated recipes..."
tagged_count = 0

Recipe.where(source_type: "cucharada").find_each do |recipe|
  title_lower = recipe.title.downcase

  title_words = title_lower.split(/\s+/)
  TAG_KEYWORDS.each do |tag_name, keywords|
    matched = keywords.any? do |kw|
      if kw.include?(" ")
        title_lower.include?(kw)
      else
        title_words.any? { |w| w == kw || w == kw + "s" || w == kw + "es" }
      end
    end
    if matched
      tag = Tag.find_by(name: tag_name)
      RecipeTag.find_or_create_by!(recipe: recipe, tag: tag) if tag
    end
  end

  # Auto-tag "Rápido" if total time <= 30 minutes
  total_time = (recipe.prep_time || 0) + (recipe.cook_time || 0)
  if total_time > 0 && total_time <= 30
    rapid_tag = Tag.find_by(name: "Rápido")
    RecipeTag.find_or_create_by!(recipe: recipe, tag: rapid_tag) if rapid_tag
  end

  tagged_count += 1
end

puts "  Auto-tagged #{tagged_count} curated recipes."
