class GeminiService
  BASE_URL = "https://generativelanguage.googleapis.com/v1beta/models".freeze
  MODELS = %w[gemini-2.0-flash-lite gemini-2.5-flash-lite gemini-2.0-flash].freeze
  MAX_RETRIES = 1

  RECIPE_PROMPT = <<~PROMPT
    Sos un asistente experto en cocina argentina. Analizá esta receta y devolvé un JSON con la siguiente estructura exacta:
    {
      "title": "Nombre de la receta",
      "description": "Breve descripción de la receta",
      "servings": 4,
      "prep_time": 30,
      "cook_time": 45,
      "ingredients": [
        { "name": "Harina 0000", "quantity": "500", "unit": "g", "notes": "tamizada" }
      ],
      "steps": [
        { "step_number": 1, "instruction": "Precalentar el horno a 180 grados." }
      ]
    }

    Reglas importantes:
    - Usá nombres de ingredientes como se dicen en Argentina (ej: "palta" no "aguacate", "choclo" no "elote", "frutilla" no "fresa")
    - Las cantidades deben estar separadas de las unidades
    - Si no encontrás un dato, poné null
    - Respondé SOLO con el JSON, sin texto adicional ni markdown
    - Los pasos deben ser claros y detallados
  PROMPT

  def initialize
    @api_key = Rails.application.credentials.dig(:gemini, :api_key) || ENV["GEMINI_API_KEY"]
    raise "Gemini API key not configured" unless @api_key
  end

  def extract_from_image(image_data, mime_type = "image/jpeg")
    encoded_image = Base64.strict_encode64(image_data)

    payload = {
      contents: [
        {
          parts: [
            { text: RECIPE_PROMPT },
            { inline_data: { mime_type: mime_type, data: encoded_image } }
          ]
        }
      ]
    }

    call_with_fallback(payload)
  end

  def extract_from_text(text)
    payload = {
      contents: [
        {
          parts: [
            { text: "#{RECIPE_PROMPT}\n\nReceta a analizar:\n#{text}" }
          ]
        }
      ]
    }

    call_with_fallback(payload)
  end

  private

  def call_with_fallback(payload)
    last_error = nil

    MODELS.each do |model|
      result = try_model(model, payload)
      return result if result
    rescue => e
      last_error = e
      Rails.logger.warn "Model #{model} failed: #{e.message}, trying next..."
    end

    raise last_error || RuntimeError.new("Todos los modelos de Gemini fallaron")
  end

  def try_model(model, payload)
    (MAX_RETRIES + 1).times do |attempt|
      response = make_request(model, payload)

      if response.status == 429
        if attempt < MAX_RETRIES
          wait_time = (attempt + 1) * 2
          Rails.logger.warn "#{model} rate limit, retry #{attempt + 1}/#{MAX_RETRIES} in #{wait_time}s"
          sleep(wait_time)
          next
        else
          raise "Rate limit agotado en #{model}"
        end
      end

      unless response.success?
        Rails.logger.error "Gemini error (#{model}): #{response.status} - #{response.body}"
        raise "Error de Gemini #{model} (#{response.status})"
      end

      return parse_response(response, model)
    end
  end

  def make_request(model, payload)
    url = "#{BASE_URL}/#{model}:generateContent"
    conn = Faraday.new(url: url) do |f|
      f.request :json
      f.response :json
      f.options.timeout = 30
      f.options.open_timeout = 10
      f.adapter Faraday.default_adapter
    end
    conn.post("?key=#{@api_key}", payload)
  end

  def parse_response(response, model)
    text = response.body.dig("candidates", 0, "content", "parts", 0, "text")
    raise "Respuesta vacía de #{model}" unless text

    clean_text = text.gsub(/```json\n?/, "").gsub(/```\n?/, "").strip
    JSON.parse(clean_text)
  rescue JSON::ParserError => e
    Rails.logger.error "Error parsing #{model} response: #{e.message}\nResponse: #{text}"
    raise "No se pudo interpretar la respuesta de #{model}"
  end
end
