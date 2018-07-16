class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: sess[:email].downcase
    if user&.authenticate(sess[:password])
      if user.activated?
        log_in user
        sess[:remember_me] == "1" ? remember(user) : forget(user)
        redirect_back_or user
      else
        flash[:warning] = t "flash.not_active"
        redirect_to root_url
      end
    else
      flash.now[:danger] = t "flash.invalid"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private
  def sess
    params[:session]
  end
end
