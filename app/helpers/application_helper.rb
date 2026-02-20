module ApplicationHelper
  CUCHARADA_EMAIL = "cucharada@cucharada.app".freeze

  def curated_recipe?(recipe)
    recipe.source_type == "cucharada"
  end

end
