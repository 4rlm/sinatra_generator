module UsersHelper

  # UPDATE: Method for patch and put
  def update_user
    @user = User.find(params[:id])
    @user.update(params[:user])
    redirect "/users/#{@user.id}"
  end

end
helpers UsersHelper
