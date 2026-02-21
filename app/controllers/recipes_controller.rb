class RecipesController < ApplicationController
  before_action :require_login, except: [ :index, :show ]
  before_action :set_recipe, only: [ :show, :edit, :update, :destroy, :cooking_mode ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy ]

  def index
    per_page = 12
    page = (params[:page] || 1).to_i
    @query = params[:q]&.strip

    # Recipe of the day: deterministic daily pick from curated recipes
    if page == 1 && @query.blank?
      curated_count = Recipe.where(source_type: "cucharada").count
      if curated_count > 0
        daily_seed = Date.today.to_s.hash.abs
        @recipe_of_the_day = Recipe.without_base64
                                   .where(source_type: "cucharada")
                                   .includes(:user, :ratings, :tags)
                                   .offset(daily_seed % curated_count)
                                   .limit(1)
                                   .first
      end
    end

    curated_scope = Recipe.without_base64.where(source_type: "cucharada")
    community_scope = Recipe.without_base64
                            .where.not(source_type: "cucharada")
                            .where.not(user_id: cucharada_user_ids)
                            .publicly_visible

    if @query.present?
      curated_scope = curated_scope.full_text_search(@query)
      community_scope = community_scope.full_text_search(@query)
    end

    @curated_total = curated_scope.count
    @curated_recipes = curated_scope.includes(:user, :ratings, :tags)
                                    .order(created_at: :desc)
                                    .offset((page - 1) * per_page)
                                    .limit(per_page)

    @community_recipes = community_scope.includes(:user, :ratings, :tags)
                                        .order(created_at: :desc)
                                        .limit(per_page)

    if logged_in?
      @community_recipes = @community_recipes.where.not(user: current_user)
    end
  end

  def my_recipes
    @query = params[:q]&.strip
    scope = current_user.recipes

    if @query.present?
      scope = scope.full_text_search(@query)
    end

    @recipes = scope.without_base64.includes(:user, :ratings, :tags)
                    .order(created_at: :desc)
  end

  def show
    if @recipe.private? && (!logged_in? || @recipe.user != current_user)
      redirect_to recipes_path, alert: "Esa receta es privada."
      return
    end
  end

  def cooking_mode
    if @recipe.private? && (!logged_in? || @recipe.user != current_user)
      redirect_to recipes_path, alert: "Esa receta es privada."
      return
    end
    render layout: "cooking"
  end

  def new
    @recipe = Recipe.new
  end

  def create
    case params[:import_type]
    when "photo"
      create_from_photo
    when "link"
      create_from_link
    else
      create_manual
    end
  end

  def edit
  end

  def update
    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: "Receta actualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe.destroy
    redirect_to recipes_path, notice: "Receta eliminada."
  end

  private

  def cucharada_user_ids
    @cucharada_user_ids ||= User.where(email: ApplicationHelper::CUCHARADA_EMAIL).pluck(:id)
  end

  def set_recipe
    @recipe = Recipe.includes(:recipe_ingredients, :ingredients, :recipe_steps, :ratings, :comments, :tags, :cook_photos).find(params[:id])
  end

  def authorize_owner!
    unless @recipe.user == current_user
      redirect_to recipes_path, alert: "No tenés permiso para modificar esta receta."
    end
  end

  def recipe_params
    params.require(:recipe).permit(
      :title, :description, :inspired_by, :servings, :prep_time, :cook_time, :image, :visibility,
      tag_ids: [],
      recipe_ingredients_attributes: [ :id, :ingredient_id, :quantity, :unit, :notes, :_destroy ],
      recipe_steps_attributes: [ :id, :step_number, :instruction, :_destroy ]
    )
  end

  def create_from_photo
    unless params[:recipe_image].present?
      flash[:alert] = "Tenés que subir una foto de la receta."
      redirect_to new_recipe_path and return
    end

    parser = RecipeParserService.new(current_user)
    uploaded = params[:recipe_image]

    blob = ActiveStorage::Blob.create_and_upload!(
      io: uploaded,
      filename: uploaded.original_filename,
      content_type: uploaded.content_type
    )

    @recipe = parser.from_image(blob)
    @recipe.update_column(:visibility, "private")
    redirect_to @recipe, notice: "Receta importada desde foto correctamente."
  rescue => e
    Rails.logger.error "Error importing from photo: #{e.message}"
    flash[:alert] = friendly_error(e)
    redirect_to new_recipe_path
  end

  def create_from_link
    url = params[:recipe_url]&.strip
    unless url.present? && url.match?(/\Ahttps?:\/\//i)
      flash[:alert] = "Tenés que ingresar una URL válida."
      redirect_to new_recipe_path and return
    end

    parser = RecipeParserService.new(current_user)
    @recipe = parser.from_url(url)
    @recipe.update_column(:visibility, "private")
    redirect_to @recipe, notice: "Receta importada desde link correctamente."
  rescue => e
    Rails.logger.error "Error importing from URL: #{e.message}"
    flash[:alert] = friendly_error(e)
    redirect_to new_recipe_path
  end

  def friendly_error(error)
    msg = error.message
    if msg.include?("saturado") || msg.include?("429") || msg.include?("rate")
      "Estamos procesando muchas recetas. Intentá de nuevo en unos minutos."
    elsif msg.include?("API key")
      "Hay un problema de configuración. Contactá al administrador."
    elsif msg.include?("vacía") || msg.include?("interpretar")
      "No pudimos extraer la receta. Probá con otra foto o link."
    elsif msg.include?("extraer contenido")
      "No pudimos leer esa página. Verificá que el link sea correcto."
    else
      "Algo salió mal al importar la receta. Intentá de nuevo."
    end
  end

  def create_manual
    @recipe = current_user.recipes.new(recipe_params)
    @recipe.source_type = "manual"

    if @recipe.save
      redirect_to @recipe, notice: "Receta creada correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end
end
