class FavoritesController < ApplicationController
  before_action :require_login

  def index
    @recipes = current_user.favorite_recipes.without_base64.includes(:user, :ratings, :tags).order("favorites.created_at DESC")
  end

  def create
    recipe = Recipe.find(params[:recipe_id])
    current_user.favorites.find_or_create_by(recipe: recipe)
    redirect_back fallback_location: recipe_path(recipe), notice: "Receta agregada a favoritos."
  end

  def destroy
    favorite = current_user.favorites.find(params[:id])
    favorite.destroy
    redirect_back fallback_location: favorites_path, notice: "Receta eliminada de favoritos."
  end
end
