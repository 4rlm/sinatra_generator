# require 'rack-flash'

class ApplicationController < Sinatra::Base

  # use Rack::Flash

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    # enable :sessions
    # set :session_secret, "password_security"
  end

  get '/' do
    # 'home page'
    erb :'index'
  end

  helpers do
    def redirect_to_home_page
      redirect to "/"
    end

    def redirect_to_accounts
      redirect to "/accounts"
    end

    def redirect_to_contacts
      redirect to "/contacts"
    end
  end

end
