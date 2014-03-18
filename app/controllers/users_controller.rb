class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    authorize! :index, @user, :message => t(:not_authorized_as_an_administrator)
    @users = User.all
  end

  def show
    authorize! :show, @user, :message => t(:not_authorized_as_an_administrator)
    @user = User.find(params[:id])
  end
  
  def update
    authorize! :update, @user, :message => t(:not_authorized_as_an_administrator)
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user], :as => :admin)
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end
    
  def destroy
    authorize! :destroy, @user, :message => t(:not_authorized_as_an_administrator)
    user = User.find(params[:id])
    unless user == current_user
      user.destroy
      redirect_to users_path, :notice => "User deleted."
    else
      redirect_to users_path, :notice => "Can't delete yourself."
    end
  end

  def edit
    set_traveler_id params[:id] || current_user
    redirect_to edit_user_registration_path
  end

private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
  
end
