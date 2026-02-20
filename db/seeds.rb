# Load ingredients
load Rails.root.join("db/seeds/ingredients.rb")

# Load curated recipes (requires recipes_data.json from rake generate_recipes)
load Rails.root.join("db/seeds/recipes.rb")

# Load tags and auto-tag curated recipes
load Rails.root.join("db/seeds/tags.rb")

puts "Seeds completed!"
