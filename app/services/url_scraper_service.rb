class UrlScraperService
  USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36".freeze

  def initialize(url)
    @url = url
  end

  # Download HTML from URL and extract relevant recipe text
  def scrape
    response = fetch_url
    extract_text(response.body)
  end

  private

  def fetch_url
    conn = Faraday.new do |f|
      f.headers["User-Agent"] = USER_AGENT
      f.response :raise_error
      f.adapter Faraday.default_adapter
      f.options.timeout = 15
      f.options.open_timeout = 10
    end

    conn.get(@url)
  rescue Faraday::Error => e
    raise "No se pudo acceder a la URL: #{e.message}"
  end

  def extract_text(html)
    doc = Nokogiri::HTML(html)

    # Remove scripts, styles, and irrelevant elements
    doc.css("script, style, nav, header, footer, aside, .ad, .sidebar, .comments").remove

    # Try to find the main recipe content
    content = find_recipe_content(doc) || doc.css("main, article, .recipe, .post-content, .entry-content, body").first

    return "" unless content

    # Clean and return text
    content.text.gsub(/\s+/, " ").strip.slice(0, 5000)
  end

  def find_recipe_content(doc)
    # Search for recipe schemas (many sites use structured data)
    recipe_schema = doc.css('[itemtype*="Recipe"], [type="application/ld+json"]')

    if recipe_schema.any?
      ld_json = doc.css('script[type="application/ld+json"]')
      ld_json.each do |script|
        data = JSON.parse(script.text) rescue next
        # Can be an array or an object
        data = data.first if data.is_a?(Array)
        if data.is_a?(Hash) && data["@type"]&.include?("Recipe")
          return Nokogiri::HTML("<div>#{data.to_json}</div>").css("div").first
        end
      end
    end

    nil
  end
end
