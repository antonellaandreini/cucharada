class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email]&.downcase&.strip)

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Bienvenido/a, #{user.name}!"
    else
      flash.now[:alert] = "Email o contraseña incorrectos."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    @current_user = nil
    redirect_to root_path, notice: "Cerraste sesión correctamente."
  end
end
