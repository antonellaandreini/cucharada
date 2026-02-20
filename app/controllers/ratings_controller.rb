class RatingsController < ApplicationController
  before_action :require_login
  before_action :set_recipe

  def create
    unless @recipe.public?
      redirect_to recipe_path(@recipe), alert: "No se puede calificar una receta privada." and return
    end

    if @recipe.user == current_user
      redirect_to recipe_path(@recipe), alert: "No podés calificar tu propia receta." and return
    end

    rating = current_user.ratings.find_or_initialize_by(recipe: @recipe)
    rating.score = params[:score].to_i

    if rating.save
      redirect_to recipe_path(@recipe), notice: "Calificación guardada."
    else
      redirect_to recipe_path(@recipe), alert: "No se pudo guardar la calificación."
    end
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:recipe_id])
  end
end
