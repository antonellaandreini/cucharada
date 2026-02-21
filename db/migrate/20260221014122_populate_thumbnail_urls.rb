class PopulateThumbnailUrls < ActiveRecord::Migration[8.1]
  def up
    json_path = Rails.root.join("db/seeds/recipes_data.json")
    return unless File.exist?(json_path)

    recipes_data = JSON.parse(File.read(json_path))

    # Build lookup: [title, chef_name] => thumbnail_url
    url_map = {}
    recipes_data.each do |data|
      url = data["thumbnail_url"]
      next unless url.present?
      url_map[[data["title"]&.strip, data["chef_name"]&.strip]] = url
    end

    say "Populating thumbnail_url for #{url_map.size} recipes..."

    updated = 0
    execute("SELECT id, title, chef_name FROM recipes WHERE source_type = 'cucharada'").each do |row|
      key = [row["title"]&.strip, row["chef_name"]&.strip]
      url = url_map[key]
      if url
        execute("UPDATE recipes SET thumbnail_url = #{ActiveRecord::Base.connection.quote(url)} WHERE id = #{row["id"]}")
        updated += 1
      end
    end

    say "Updated #{updated} recipes with thumbnail URLs"
  end

  def down
    execute("UPDATE recipes SET thumbnail_url = NULL WHERE source_type = 'cucharada'")
  end
end
