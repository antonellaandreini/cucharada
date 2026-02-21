namespace :recipes do
  desc "Fetch thumbnail image URLs from Pexels for curated recipes"
  task download_thumbnails: :environment do
    $stdout.sync = true
    api_key = ENV["PEXELS_API_KEY"]
    abort "Set PEXELS_API_KEY in .env" unless api_key.present?

    require "faraday"

    # Map Spanish title keywords -> English Pexels search terms for PLATED FOOD
    # Each category: [keywords_to_match, pexels_search_query]
    FOOD_CATEGORIES = [
      # Empanadas
      [%w[empanada empanadas], "empanadas baked golden plate"],
      # Milanesas
      [%w[milanesa milanesas suprema], "schnitzel breaded cutlet plate served"],
      # Asado / parrilla
      [%w[asado parrilla vacío entraña choripán choripan], "grilled meat barbecue plate served"],
      # Chorizo
      [%w[chorizo], "chorizo sausage grilled plate"],
      # Pastas
      [%w[pasta fideos tallarines espagueti spaghetti], "pasta plate served italian"],
      [%w[ñoqui ñoquis gnocchi], "gnocchi plate served sauce"],
      [%w[ravioles ravioli], "ravioli plate served"],
      [%w[lasaña lasagna], "lasagna plate served"],
      [%w[sorrentinos canelones], "stuffed pasta plate served"],
      # Pizza
      [%w[pizza fugazzeta fugazza], "pizza homemade plate"],
      [%w[fainá], "chickpea flatbread plate"],
      # Tartas
      [%w[tarta tartas quiché quiche], "savory tart quiche slice plate"],
      [%w[pascualina], "spinach pie slice plate"],
      # Guisos / estofados
      [%w[guiso guisos estofado], "stew bowl served hearty"],
      [%w[locro], "corn bean stew bowl traditional"],
      [%w[carbonada], "meat stew pumpkin bowl"],
      # Sopas
      [%w[sopa sopas crema\ de caldo], "soup bowl served creamy"],
      # Pollo
      [%w[pollo], "chicken dish plate served cooked"],
      # Cerdo
      [%w[cerdo bondiola lechón], "pork dish plate served roasted"],
      [%w[costilla costillas costillitas], "ribs plate served bbq"],
      # Carne vacuna
      [%w[bife lomo], "steak plate served dinner"],
      [%w[carne carnes peceto colita matambre], "beef dish plate served"],
      # Pescado
      [%w[merluza pescado trucha], "fish fillet plate served cooked"],
      [%w[salmón salmon], "salmon plate served dinner"],
      [%w[calamar rabas], "fried calamari plate served"],
      [%w[langostino camarón mariscos], "shrimp seafood plate served"],
      # Ensaladas
      [%w[ensalada ensaladas], "fresh salad plate served"],
      # Pan / panificados
      [%w[pan focaccia brioche], "fresh bread homemade baked"],
      [%w[medialunas medialuna croissant], "croissants pastry breakfast plate"],
      # Sandwiches
      [%w[lomito sándwich sandwich tostado], "sandwich plate served toasted"],
      # Postres
      [%w[flan], "flan caramel dessert plate"],
      [%w[chocotorta], "chocolate cake dessert plate served"],
      [%w[brownie brownies], "brownie chocolate dessert plate"],
      [%w[mousse], "mousse dessert glass served"],
      [%w[tiramisú tiramisu], "tiramisu dessert plate served"],
      [%w[cheesecake], "cheesecake slice plate dessert"],
      [%w[torta], "cake slice plate dessert served"],
      [%w[helado], "ice cream bowl dessert served"],
      [%w[budín budin], "pudding loaf cake dessert slice"],
      # Dulces / alfajores
      [%w[alfajor alfajores], "sandwich cookies dulce de leche"],
      [%w[galletita galletitas cookie cookies], "homemade cookies plate"],
      [%w[mermelada dulce\ de], "jam preserves jar"],
      # Pionono
      [%w[pionono piononos], "swiss roll filled savory appetizer"],
      # Bebidas
      [%w[licuado smoothie], "smoothie glass fruit healthy"],
      # Desayuno
      [%w[desayuno tostada tostadas], "breakfast toast plate served"],
      [%w[panqueque panqueques crepe crepes], "crepes pancakes plate served"],
      [%w[granola], "granola bowl yogurt breakfast"],
      # Entradas
      [%w[provoleta], "grilled cheese melted appetizer"],
      [%w[bruschetta], "bruschetta appetizer plate served"],
      [%w[hummus], "hummus dip plate appetizer"],
      # Empanadas especiales
      [%w[humita], "corn filling traditional dish"],
      # Arroz
      [%w[arroz risotto paella], "rice dish plate served"],
      # Salsa
      [%w[chimichurri], "chimichurri sauce bowl herbs"],
      [%w[salsa], "sauce bowl fresh homemade"],
      # Picada
      [%w[picada tabla], "charcuterie board appetizer platter"],
      # Postres varios
      [%w[postre postres], "dessert plate served sweet"],
      # Dulce de leche
      [%w[dulce\ de\ leche], "dulce de leche caramel dessert"],
      # Tortilla
      [%w[tortilla], "spanish omelette tortilla plate"],
      # Revuelto
      [%w[revuelto revueltos], "scrambled eggs dish plate"],
      # Hamburguesa
      [%w[hamburguesa burger], "hamburger plate served"],
      # Croquetas
      [%w[croqueta croquetas], "croquettes plate fried appetizer"],
      # Wok
      [%w[wok salteado], "stir fry wok dish plate"],
    ].freeze

    # Fallback for unmatched recipes
    FALLBACK_QUERIES = [
      "homemade food plate served dinner",
      "traditional food plate served",
      "latin american food dish served",
      "home cooked meal plate",
      "comfort food plate served dinner",
    ].freeze

    conn = Faraday.new(url: "https://api.pexels.com") do |f|
      f.headers["Authorization"] = api_key
      f.request :url_encoded
      f.adapter Faraday.default_adapter
      f.options.timeout = 15
      f.options.open_timeout = 10
    end

    recipes = Recipe.where(source_type: "cucharada")
                    .where(thumbnail_url: [nil, ""])
                    .order(:id)
    total = recipes.count
    puts "Found #{total} curated recipes without thumbnail URLs"
    next if total == 0

    # Step 1: Categorize recipes
    puts "\nStep 1: Categorizing recipes..."
    categorized = {}  # query => [recipes]
    uncategorized = []

    recipes.find_each do |recipe|
      title_lower = recipe.title.downcase
      title_words = title_lower.split(/\s+/)

      matched_query = nil
      FOOD_CATEGORIES.each do |keywords, query|
        if keywords.any? { |kw| kw.include?(" ") ? title_lower.include?(kw) : title_words.include?(kw) }
          matched_query = query
          break
        end
      end

      if matched_query
        categorized[matched_query] ||= []
        categorized[matched_query] << recipe
      else
        uncategorized << recipe
      end
    end

    puts "  #{categorized.size} categories matched"
    puts "  #{uncategorized.size} uncategorized recipes"
    categorized.sort_by { |_q, rs| -rs.size }.first(10).each do |q, rs|
      puts "    #{q}: #{rs.size} recipes"
    end

    # Step 2: Fetch image URLs per category
    puts "\nStep 2: Fetching image URLs from Pexels..."
    assigned = 0
    api_calls = 0
    cache = {} # query => [urls]

    categorized.each_with_index do |(query, group_recipes), idx|
      # Calculate how many photos we need (more variety for larger groups)
      photos_needed = [group_recipes.size, 30].min
      per_page = [photos_needed, 40].min

      urls = fetch_image_urls(conn, query, per_page: per_page)
      api_calls += 1

      # If too few results, try a simpler query
      if urls.size < 3
        simple_query = query.split.first(3).join(" ") + " food plate"
        urls = fetch_image_urls(conn, simple_query, per_page: per_page)
        api_calls += 1
      end

      if urls.empty?
        print "x"
        uncategorized.concat(group_recipes)
        next
      end

      cache[query] = urls

      # Assign URLs to recipes (cycle through available URLs)
      group_recipes.shuffle.each_with_index do |recipe, i|
        recipe.update_column(:thumbnail_url, urls[i % urls.size])
        assigned += 1
      end

      print "."
      puts " [#{assigned}/#{total}]" if (idx + 1) % 10 == 0

      # Rate limit: stay under 200 req/hour (1 every 18s to be safe, but batch)
      sleep 1
    end

    # Step 3: Handle uncategorized with fallback URLs
    if uncategorized.any?
      puts "\n\nStep 3: Fetching fallback URLs for #{uncategorized.size} uncategorized recipes..."

      all_fallback = []
      FALLBACK_QUERIES.each do |query|
        urls = fetch_image_urls(conn, query, per_page: 40)
        api_calls += 1
        all_fallback.concat(urls)
        sleep 1
      end

      if all_fallback.any?
        all_fallback.shuffle!
        uncategorized.each_with_index do |recipe, idx|
          recipe.update_column(:thumbnail_url, all_fallback[idx % all_fallback.size])
          assigned += 1
        end
        puts "  Assigned #{uncategorized.size} recipes with fallback URLs"
      end
    end

    final = Recipe.where(source_type: "cucharada").where.not(thumbnail_url: [nil, ""]).count
    puts "\nDone! #{final}/#{total} curated recipes now have thumbnail URLs."
    puts "API calls used: #{api_calls}"
  end
end

def fetch_image_urls(conn, query, per_page: 15)
  urls = []

  begin
    response = nil
    3.times do |attempt|
      response = conn.get("/v1/search", { query: query, per_page: per_page, orientation: "landscape" })

      if response.status == 200
        break
      elsif response.status == 429
        wait = (attempt + 1) * 15
        puts "\n  Rate limited, waiting #{wait}s..."
        sleep wait
        response = nil
      else
        puts "\n  Pexels error #{response.status} for '#{query}'"
        return urls
      end
    end

    return urls unless response&.status == 200

    photos = JSON.parse(response.body)["photos"] || []

    photos.each do |photo|
      url = photo.dig("src", "medium")
      next unless url.present?
      # Use smaller dimensions for faster loading
      url = url.sub("h=350", "h=250&w=400")
      urls << url
    end
  rescue => e
    puts "\n  Error: #{e.message}"
  end

  urls
end
