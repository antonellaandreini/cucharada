namespace :recipes do
  desc "Export thumbnail_url from DB into recipes_data.json for seeding"
  task export_thumbnails: :environment do
    json_path = Rails.root.join("db/seeds/recipes_data.json")
    abort "#{json_path} not found" unless File.exist?(json_path)

    recipes_data = JSON.parse(File.read(json_path))
    puts "Loaded #{recipes_data.size} recipes from JSON"

    # Build lookup: [title, chef_name] => thumbnail_url
    url_map = {}
    Recipe.where(source_type: "cucharada")
          .where.not(thumbnail_url: [nil, ""])
          .pluck(:title, :chef_name, :thumbnail_url)
          .each { |title, chef, url| url_map[[title.strip, chef&.strip]] = url }

    puts "Found #{url_map.size} recipes with thumbnail URLs in DB"

    updated = 0
    recipes_data.each do |data|
      key = [data["title"]&.strip, data["chef_name"]&.strip]
      url = url_map[key]
      if url
        data["thumbnail_url"] = url
        updated += 1
      end
    end

    File.write(json_path, JSON.pretty_generate(recipes_data))
    puts "Updated #{updated} recipes in #{json_path}"
  end
end
