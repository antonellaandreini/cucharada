class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_recipe

  def create
    unless @recipe.public?
      redirect_to recipe_path(@recipe), alert: "No se puede comentar una receta privada." and return
    end

    if @recipe.user == current_user
      redirect_to recipe_path(@recipe), alert: "No podés comentar tu propia receta." and return
    end

    comment = current_user.comments.new(recipe: @recipe, body: params[:comment][:body])

    if comment.save
      redirect_to recipe_path(@recipe), notice: "Comentario agregado."
    else
      redirect_to recipe_path(@recipe), alert: "No se pudo guardar el comentario."
    end
  end

  def destroy
    comment = @recipe.comments.find(params[:id])

    unless comment.user == current_user
      redirect_to recipe_path(@recipe), alert: "No podés eliminar este comentario." and return
    end

    comment.destroy
    redirect_to recipe_path(@recipe), notice: "Comentario eliminado."
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:recipe_id])
  end
end
