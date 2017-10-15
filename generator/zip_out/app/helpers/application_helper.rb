module ApplicationHelper

  # flash[:message] = "Please Enter a Category Name"
  # flash[:alert] = "Hooray, Flash is working!"
  # flash[:success_alert] = "It was successful!"
  # flash[:error_alert] = "There was an error."

  def logged_in
    if session[:user_id].present?
      @user = User.find(session[:user_id])
      return true if @user.present?
    else
      return false
    end
  end

  def redirect_to_home_page
    erb :'index'
  end

  def redirect_to_users
    redirect '/users'
  end

end
helpers ApplicationHelper
