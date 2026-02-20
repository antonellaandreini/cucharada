class ShoppingListsController < ApplicationController
  before_action :require_login
  before_action :set_shopping_list, only: [:show, :destroy, :toggle_item, :remove_item, :add_recipe, :add_item]

  def index
    @shopping_lists = current_user.shopping_lists.includes(:items).order(updated_at: :desc)
  end

  def show
    @unchecked_items = @shopping_list.items.unchecked.includes(:ingredient, :recipe).order(:created_at)
    @checked_items = @shopping_list.items.checked.includes(:ingredient, :recipe).order(:updated_at)
  end

  def create
    if params[:shopping_list_id].present?
      # Adding recipe to existing list
      existing_list = current_user.shopping_lists.find(params[:shopping_list_id])
      recipe = Recipe.find(params[:recipe_id])
      existing_list.add_recipe_ingredients(recipe)
      redirect_to existing_list, notice: "Ingredientes de \"#{recipe.title}\" agregados."
    else
      @shopping_list = current_user.shopping_lists.create!(name: params[:name])

      if params[:recipe_id].present?
        recipe = Recipe.find(params[:recipe_id])
        @shopping_list.add_recipe_ingredients(recipe)
        redirect_to @shopping_list, notice: "Lista creada con ingredientes de \"#{recipe.title}\"."
      else
        redirect_to @shopping_list, notice: "Lista de compras creada."
      end
    end
  end

  def destroy
    @shopping_list.destroy
    redirect_to shopping_lists_path, notice: "Lista eliminada."
  end

  def toggle_item
    item = @shopping_list.items.find(params[:item_id])
    item.update!(checked: !item.checked)

    respond_to do |format|
      format.html { redirect_to @shopping_list }
      format.json { render json: { checked: item.checked } }
    end
  end

  def remove_item
    item = @shopping_list.items.find(params[:item_id])
    item.destroy
    redirect_to @shopping_list, notice: "Ingrediente eliminado."
  end

  def add_recipe
    recipe = Recipe.find(params[:recipe_id])
    @shopping_list.add_recipe_ingredients(recipe)
    redirect_to @shopping_list, notice: "Ingredientes de \"#{recipe.title}\" agregados."
  end

  def add_item
    ingredient = Ingredient.find_or_create_by!(name: params[:ingredient_name].strip)
    ShoppingListItem.find_or_create_by!(shopping_list: @shopping_list, ingredient: ingredient) do |item|
      item.quantity = params[:quantity].presence
      item.unit = params[:unit].presence
    end
    redirect_to @shopping_list, notice: "\"#{ingredient.name}\" agregado."
  end

  def download_pdf
    list = current_user.shopping_lists.find(params[:list_id])
    unchecked = list.items.unchecked.includes(:ingredient).order(:created_at)
    checked = list.items.checked.includes(:ingredient).order(:updated_at)

    html = render_to_string(
      partial: "shopping_lists/pdf",
      locals: { list: list, unchecked: unchecked, checked: checked },
      layout: false
    )

    send_data html, filename: "lista-#{list.display_name.parameterize}.html",
                     type: "text/html",
                     disposition: "attachment"
  end

  private

  def set_shopping_list
    @shopping_list = current_user.shopping_lists.find(params[:id])
  end
end
