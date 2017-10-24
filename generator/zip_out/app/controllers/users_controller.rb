class UsersController < ApplicationController
  include UsersHelper

  # before "/*" do
  #   logged_in
  #   binding.pry
  # end


  # before "/channels/*" do
  #   logged_in
  # end

  # Sample Before/After Hook
  # before "/entries/*" do
  #   if !request.post?
  #     if !logged_in
  #         @alert_msg[:danger_alert] = "Please login to post new entries."
  #       erb :'users/login'
  #     end
  #   end
  # end

  # sinatra request objects
  # request.methods
  # request.post

  get '/users' do
    !logged_in ? (erb :'users/login') : logged_in
  end

  get '/users/index' do
    if !logged_in
      @alert_msg[:danger_alert] = "Please login to view members."
      erb :'users/login'
    else
      # @users = User.order('updated_at ASC').limit(10)
      @users = User.all.order("updated_at DESC").paginate(page: params[:page], per_page: 5)
      erb :'users/index'
    end
  end

  get '/users/register' do
    !logged_in ? (erb :'users/register') : redirect_to_home_page
  end

  post '/users/register' do
    if params[:user][:username].empty? || params[:user][:email].empty? || params[:user][:password].empty?

      @alert_msg[:danger_alert] = "Please don't leave blank content."
      erb :'/users/register'
    else
      user = User.create(params[:user])
      if user && user.valid?
        @user = user
        session[:user_id] = @user.id
        @alert_msg[:success_alert] = "Welcome, #{@user.username}!"
        redirect_to_home_page
      else
        @alert_msg[:danger_alert] = "Email address already registered."
        erb :'/users/register'
      end
    end
  end

  get '/users/login' do
    !logged_in ? (erb :'users/login') : redirect_to_home_page
  end

  post '/users/login' do
    if not logged_in
      if params[:user][:email].empty? || params[:user][:password].empty?

        @alert_msg[:danger_alert] = "Please don't leave blank content"
        erb :'users/login'
      else
        @user = User.authenticate(params[:user][:email], params[:user][:password])
        if @user
          session[:user_id] = @user.id
          @alert_msg[:success_alert] = "Welcome, #{@user.username}!"
          # erb :'index'
          erb :'users/show'
        else
          @alert_msg[:danger_alert] = "We can't find you, Please try again"
          erb :'users/login'
        end
      end
    end
  end

  ## Logout & Show Page
  get '/users/:id' do
    if params[:id] == "logout"
      session[:user_id] = nil
      @user = nil
      @alert_msg[:danger_alert] = "Goodbye!  Please login to return."
      erb :'/users/login'
    else
      @user = User.find(params[:id])
      @alert_msg[:success_alert] = "#{@user.username} Account Details"
      erb :'users/show'
    end
  end

  # EDIT:
  get '/users/:id/edit' do
    @user = User.find(params[:id])
    erb :'users/edit'
  end

  # UPDATE: patch
  patch '/users/:id' do
    update_user
  end

  # UPDATE: put
  put '/users/:id' do
    update_user
  end

  # DELETE:
  delete '/users/:id' do
    User.find(params[:id]).destroy!
    session[:user_id] = nil
    @user = nil
    @alert_msg[:danger_alert] = "Account Deleted. Please re-register to continue."
    erb :'/users/register'
  end

end
