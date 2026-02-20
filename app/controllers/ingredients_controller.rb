class IngredientsController < ApplicationController
  def search
    query = params[:q]&.strip
    @ingredients = if query.present? && query.length >= 2
      Ingredient.search_by_name(query).limit(20)
    else
      Ingredient.none
    end

    render partial: "ingredients/results", locals: { ingredients: @ingredients }
  end
end
