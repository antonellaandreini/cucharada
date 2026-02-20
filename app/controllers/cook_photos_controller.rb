class CookPhotosController < ApplicationController
  before_action :require_login
  before_action :set_recipe

  def create
    unless @recipe.public?
      redirect_to @recipe, alert: "Solo se pueden subir fotos a recetas públicas." and return
    end

    if @recipe.user == current_user
      redirect_to @recipe, alert: "No podés subir fotos a tu propia receta." and return
    end

    @cook_photo = @recipe.cook_photos.build(cook_photo_params)
    @cook_photo.user = current_user

    if @cook_photo.save
      redirect_to @recipe, notice: "¡Foto subida!"
    else
      redirect_to @recipe, alert: "No se pudo subir la foto."
    end
  end

  def destroy
    @cook_photo = @recipe.cook_photos.find(params[:id])

    unless @cook_photo.user == current_user
      redirect_to @recipe, alert: "No podés eliminar esta foto." and return
    end

    @cook_photo.destroy
    redirect_to @recipe, notice: "Foto eliminada."
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:recipe_id])
  end

  def cook_photo_params
    params.require(:cook_photo).permit(:image, :caption)
  end
end
