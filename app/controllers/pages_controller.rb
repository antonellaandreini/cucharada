class PagesController < ApplicationController
  def home
    @curated_recipes = Recipe.where(source_type: "cucharada")
                             .includes(:ingredients, :user, :ratings)
                             .order("RANDOM()")
                             .limit(6)

    if logged_in?
      @my_recipes = current_user.recipes
                                .includes(:ingredients, :user, :ratings)
                                .order(created_at: :desc)
                                .limit(3)
    end

    # Fallback si no hay recetas curadas todavía
    if @curated_recipes.empty?
      @recent_recipes = Recipe.includes(:ingredients, :user, :ratings).order(created_at: :desc).limit(6)
    end
  end
end
