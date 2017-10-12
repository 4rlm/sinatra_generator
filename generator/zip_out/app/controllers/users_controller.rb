class UsersController < ApplicationController
  include UsersHelper
  include ApplicationHelper

  # Sample Before/After Hook
  # before "/entries/*" do
  #   if !request.post?
  #     if !logged_in
  #       flash[:error_alert] = "Please login to post new entries."
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
      flash[:error_alert] = "Please login to view members."
      erb :'users/login'
    else
      @users = User.order('updated_at ASC').limit(10)
      erb :'users/index'
    end
  end

  get '/users/register' do
    !logged_in ? (erb :'users/register') : redirect_to_home_page
  end

  post '/users/register' do
    if params[:user][:name].empty? || params[:user][:email].empty? || params[:user][:password].empty?
      flash[:error_alert] = "Pleae don't leave blank content"
      erb :'/users/register'
    else
      user = User.create(params[:user])
      if user && user.valid?
        @user = user
        session[:user_id] = @user.id
        flash[:success_alert] = "Welcome, #{@user.name}!"
        redirect_to_home_page
      else
        flash[:error_alert] = "Email address already registered."
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
        flash[:error_alert] = "Please don't leave blank content"
        erb :'users/login'
      else
        @user = User.authenticate(params[:user][:email], params[:user][:password])
        if @user
          session[:user_id] = @user.id
          flash[:success_alert] = "Welcome, #{@user.name}!"
          redirect_to_home_page
        else
          flash[:error_alert] = "We can't find you, Please try again"
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
      flash[:error_alert] = "Goodbye!  Please login to return."
      erb :'/users/login'
    else
      @user = User.find(params[:id])
      flash[:success_alert] = "#{@user.name.capitalize} Account Details"
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
    redirect '/users'
  end

end
