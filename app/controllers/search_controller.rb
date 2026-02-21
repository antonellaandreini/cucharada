class SearchController < ApplicationController
  PER_PAGE = 12

  def index
    @query = params[:q]&.strip
    @selected_ids = params[:ingredient_ids]&.map(&:to_i) || []
    @chef = params[:chef]&.strip
    @tag = params[:tag]&.strip
    @page = (params[:page] || 1).to_i

    @chefs = Rails.cache.fetch("chef_names", expires_in: 30.minutes) do
      Recipe.where(source_type: "cucharada")
            .where.not(chef_name: [nil, ""])
            .distinct.order(:chef_name).pluck(:chef_name)
    end

    @tags = Tag.popular.limit(30)

    # Preload selected ingredients to avoid N+1 in view
    @selected_ingredients = Ingredient.where(id: @selected_ids).index_by(&:id) if @selected_ids.any?

    # Preload active tag name
    @tag_name = Tag.find_by(slug: @tag)&.name if @tag.present?

    @has_filters = @query.present? || @selected_ids.any? || @chef.present? || @tag.present?

    @recipes = build_combined_query
    @recipes = apply_visibility_filter(@recipes)
    @total = @recipes.except(:select).count
    @recipes = @recipes.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
  end

  private

  def build_combined_query
    # Don't use without_base64 when text search is active (SELECT conflict with pg_search)
    scope = @query.present? ? Recipe.includes(:user, :ratings, :tags) : Recipe.without_base64.includes(:user, :ratings, :tags)

    scope = filter_by_text(scope) if @query.present?
    scope = filter_by_ingredients(scope) if @selected_ids.any?
    scope = filter_by_chef(scope) if @chef.present?
    scope = filter_by_tag(scope) if @tag.present?

    scope.order(created_at: :desc)
  end

  def filter_by_text(scope)
    scope.full_text_search(@query)
  end

  def filter_by_ingredients(scope)
    matching_ids = Recipe.joins(:recipe_ingredients)
                        .where(recipe_ingredients: { ingredient_id: @selected_ids })
                        .group("recipes.id")
                        .having("COUNT(DISTINCT recipe_ingredients.ingredient_id) = ?", @selected_ids.size)
                        .select(:id)

    scope.where(id: matching_ids)
  end

  def filter_by_chef(scope)
    scope.where(chef_name: @chef)
  end

  def filter_by_tag(scope)
    tag = Tag.find_by(slug: @tag)
    return scope.none unless tag
    scope.where(id: RecipeTag.where(tag: tag).select(:recipe_id))
  end

  def apply_visibility_filter(scope)
    if logged_in?
      scope.where(visibility: "public").or(scope.where(user: current_user))
    else
      scope.where(visibility: "public")
    end
  end
end
