class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  before_action :find_user, only: [:show, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.users_activated.page(params[:page])
                 .per Settings.users_per_page
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "flash.check_email"
      redirect_to root_url
    else
      render :new
    end
  end

  def show
    redirect_to root_url && return unless @user
    @microposts = @user.microposts.page params[:page]
  end

  def edit; end

  def update
    if @user.update_attributes user_params
      flash[:success] = t "flash.update_success"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "flash.delete_success"
    else
      flash[:danger] = t "flash.delete_fail"
    end
    redirect_to users_url
  end

  def following
    @title = t("following").capitalize
    @user  = User.find params[:id]
    @users = @user.following.page params[:page]
    render "show_follow"
  end

  def followers
    @title = t("followers").capitalize
    @user  = User.find params[:id]
    @users = @user.followers.page params[:page]
    render "show_follow"
  end

  private
  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def find_user
    @user = User.find_by id: params[:id]

    return if @user
    flash[:warning] = t "flash.fail"
    redirect_to root_path
  end

  def correct_user
    redirect_to root_url unless @user&.current_user? current_user
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end
end
