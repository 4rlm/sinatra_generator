require 'active_support/all'
require 'pry'

module FileWriter
  extend ActiveSupport::Concern

  def generate_model_file(snake_case, model_name)
    model_path = "../#{@app_name}/app/models/#{snake_case}.rb"
    puts "Creating #{model_path}"

    File.open(model_path, 'w+') do |f|
      f.write(<<-EOF.strip_heredoc)
        class #{model_name} < ActiveRecord::Base
          # Remember to create a migration!
        end
      EOF
    end
  end

  def extract_mvc_hashes(snake_case)
    selected_table_data_hash = @mvc_hashes.find { |hash| hash[:table] == snake_case }

    fields = selected_table_data_hash[:fields]
    table_fields = []

    fields.each do |field|
      if field.include?(':')
        field_key_and_type = field.split(':')
        f_key = field_key_and_type[0]
        f_type = field_key_and_type[1]
      else
        f_key = field
        f_type = 'string'
      end
      table_fields << "t.#{f_type} :#{f_key}\n\t\t\t"
    end

    string_table_fields = table_fields.join("")
  end


  def generate_migration_file(snake_case, migration_name)
    snake_plural = snake_case.pluralize
    camel_plural = migration_name.pluralize
    filename = "#{Time.now.strftime('%Y%m%d%L')}_create_#{snake_plural}"
    migration_path = "../#{@app_name}/db/migrate/#{filename}.rb"
    puts "Creating #{migration_path}"

    string_table_fields = extract_mvc_hashes(snake_case)

    File.open(migration_path, 'w+') do |f|
      f.write(<<-EOF.gsub(/^ {8}/, ''))
        class Create#{camel_plural} < ActiveRecord::Migration[5.0]
          def change
            create_table :#{snake_plural} do |t|
              #{string_table_fields}
              t.timestamps null: false
            end
          end
        end
      EOF
    end
  end

  def generate_helper_file(snake_case, camelize)
    camel_plural = camelize.pluralize
    helper_path = "../#{@app_name}/app/helpers/#{snake_case.pluralize}_helper.rb"
    puts "Creating #{helper_path}"

    File.open(helper_path, 'w+') do |f|
      f.write(<<-EOF.strip_heredoc)
        module #{camel_plural}Helper

          def greeting
            puts "In the #{camel_plural}Helper module."
          end

        end
        helpers #{camel_plural}Helper
      EOF
    end
  end

  def generate_config_environment
    environment_path = "../#{@app_name}/config/environment.rb"
    puts "Creating #{environment_path}"

    File.open(environment_path, 'w+') do |f|
      f.write(<<-EOF.strip_heredoc)
      require 'bundler'
      Bundler.require

      configure :development do
        set :database, {
          adapter: 'postgresql',
          encoding: 'unicode',
          database: '#{@app_name}',
          pool: 5
        }
      end

      configure :production do
        set :database, {
          adapter: 'postgresql',
          encoding: 'unicode',
          database: '#{@app_name}',
          pool: 5
        }
      end

      require_all 'app'

      EOF
    end

  end

  def generate_application_controller
    routes = []
    @mvc.each do |snake_case|
      snake_plural = snake_case.pluralize
      routes << (<<-EOF.gsub(/^ {4}/, ''))
      def redirect_to_#{snake_plural}
        redirect to '/#{snake_plural}'
      end

      EOF
    end

    application_controller_path = "../#{@app_name}/app/controllers/application_controller.rb"
    puts "Creating #{application_controller_path}"

    route_strings = routes.join("")

    File.open(application_controller_path, 'w+') do |f|
      f.write(<<-EOF.gsub(/^ {6}/, ''))
      class ApplicationController < Sinatra::Base

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

      #{route_strings}

        end

      end

      EOF
    end

  end


  def generate_controller_file(snake_case, camelize)
    snake_plural = snake_case.pluralize

    controller_path = "../#{@app_name}/app/controllers/#{snake_plural}_controller.rb"
    puts "Creating #{controller_path}"

    File.open(controller_path, 'w+') do |f|
      f.write(<<-EOF.strip_heredoc)
        class #{camelize.pluralize}Controller < ApplicationController

          # #{snake_plural} home / view all page.
          get '/#{snake_plural}' do
            erb :'#{snake_plural}/index'
          end

          # #{snake_plural} create/new.
          post '/#{snake_plural}/new' do
            erb :'#{snake_plural}/create'
          end

          # displays a single #{snake_case} detail page.
          get '/#{snake_plural}/:id' do
            erb :'#{snake_plural}/show'
          end

          get '/#{snake_plural}/:id/edit' do
            erb :'#{snake_plural}/edit'
          end

          patch '/#{snake_plural}/:id' do
          end

          delete '/#{snake_plural}/:id/delete' do
            redirect_to_#{snake_plural}
          end

        end

      EOF
    end

  end



  def generate_config_ru  ## config.ru (in root)
    config_ru_path = "../#{@app_name}/config.ru"

    formatted_controllers = []
    @mvc.each do |snake_case|
      formatted_controllers << "use #{snake_case.pluralize.camelize}Controller\n"
    end

    puts "Creating #{config_ru_path}"

    controllers_list = formatted_controllers.join("")

    File.open(config_ru_path, 'w+') do |f|
      f.write(<<-EOF.gsub(/^ {6}/, ''))
      require_relative './config/environment'

      if ActiveRecord::Migrator.needs_migration?
        raise 'Migrations are pending. Run `rake db:migrate` to resolve the issue.'
      end

      use Rack::MethodOverride
      #{controllers_list}
      run ApplicationController

      EOF
    end
  end






  def generate_view_files(snake_case, view_name)
    snake_plural = snake_case.pluralize
    FileUtils.mkdir_p("../#{@app_name}/app/views/#{snake_plural}")

    # index_view_path = "../#{@app_name}/app/views/#{snake_plural}/#{snake_plural}.erb"
    # puts "Creating #{index_view_path}"
    #
    # File.open(index_view_path, 'w+') do |f|
    #   f.write(<<-EOF.strip_heredoc)
    #   <h1 style="color: white; margin: 30px 10px;">#{snake_plural} - View All</h1>
    #
    #     <div class="container" >
    #       <div class="row">
    #
    #         <div class="col-sm-8">
    #           <h1>#{snake_plural} - View All</h1>
    #         </div> <!-- end col-sm-8-->
    #
    #         <div class="col-sm-4">
    #           <h3>#{snake_plural} - View All</h3>
    #         </div> <!-- end col-sm-4-->
    #
    #       </div><!-- end row -->
    #     </div><!-- end container -->
    #   EOF
    # end

    view_files = ['index', 'create', 'show', 'edit']
    view_files.each do |view_file|
      view_path = "../#{@app_name}/app/views/#{snake_plural}/#{view_file}.erb"
      puts "Creating #{view_path}"

      File.open(view_path, 'w+') do |f|
        f.write(<<-EOF.strip_heredoc)
        <h1 style="color: white; margin: 30px 10px;">#{snake_plural} - #{view_file}</h1>

          <div class="container" >
            <div class="row">

              <div class="col-sm-8">
                <h1>#{snake_plural} - #{view_file}</h1>
              </div> <!-- end col-sm-8-->

              <div class="col-sm-4">
                <h3>#{snake_plural} - #{view_file}</h3>
              </div> <!-- end col-sm-4-->

            </div><!-- end row -->
          </div><!-- end container -->
        EOF
      end

    end

  end








  def generate_application_layout_view
    # <li><a href="/accounts">Accounts</a></li>
    # <li><a href="/contacts">Contacts</a></li>

    li_links = []
    @mvc.each do |snake_case|
      snake_plural = snake_case.pluralize
      li_links << "<li><a href='/#{snake_plural}'>#{snake_plural}</a></li>\n\t\t\t\t\t\t\t"
    end

    li_link_strings = li_links.join("")

      layout_path = "../#{@app_name}/app/views/layout.erb"
      puts "Creating #{layout_path}"

      File.open(layout_path, 'w+') do |f|
        f.write(<<-EOF.gsub(/^ {8}/, ''))
        <!DOCTYPE html>
        <html lang="en">

          <head>

            <meta charset="utf-8">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <title>#{@app_name}</title>

            <!-- CSS -->
            <link rel="stylesheet" href="http://fonts.googleapis.com/css?family=Roboto:400,100,300,500">
            <link rel="stylesheet" href="../../../assets/bootstrap/css/bootstrap.min.css">
            <link rel="stylesheet" href="../../../assets/font-awesome/css/font-awesome.min.css">
            <link rel="stylesheet" href="../../../assets/css/form-elements.css">
            <link rel="stylesheet" href="../../../assets/css/style.css">

            <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
            <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
            <!--[if lt IE 9]>
                <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
                <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
            <![endif] -->

          </head>

          <body>
            <div>
              <nav class="navbar navbar-default navbar-fixed-top">
                <div class="container-fluid">
                  <!-- Brand and toggle get grouped for better mobile display -->
                  <div class="navbar-header">
                    <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1" aria-expanded="false">
                      <span class="sr-only">Toggle navigation</span>
                      <span class="icon-bar"></span>
                      <span class="icon-bar"></span>
                      <span class="icon-bar"></span>
                    </button>
                    <a class="navbar-brand" href="/"><span class="glyphicon glyphicon-list-alt"></span> #{@app_name} </a>
                  </div>

                  <!-- Collect the nav links, forms, and other content for toggling -->
                  <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
                    <ul class="nav navbar-nav">
                      <!-- <li class="active"><a href="/">Home</a></li>
                      <li class="active"><a href="/file_magic">Helper</a></li> -->
                    </ul>

                    <ul class="nav navbar-nav navbar-right">
                      <li><a href="/#">Login</a></li>
                      <li><a href="/#">Sign-Up</a></li>
                      #{li_link_strings}
                    </ul>

                  </div><!-- /.navbar-collapse -->
                </div><!-- /.container-fluid -->
              </nav>

            <%= yield %>

            </div>

            <!-- Footer -->
            <footer>
              <div class="container">
                <div class="row">

                  <div class="col-sm-8 col-sm-offset-2">
                    <div class="footer-border"></div>
                    <p>Developed by <a href="http://www.adambooth.com" target="_blank"><strong>Adam Booth</strong></a>
                  </div>

                </div>
              </div>
            </footer>

            <!-- Javascript -->
            <script src="../../../assets/js/jquery-1.11.1.min.js"></script>
            <script src="../../../assets/bootstrap/js/bootstrap.min.js"></script>
            <script src="../../../assets/js/jquery.backstretch.min.js"></script>
            <script src="../../../assets/js/scripts.js"></script>

            <!--[if lt IE 10]>
                <script src="assets/js/placeholder.js"></script>
            <![endif]-->

          </body>

        </html>


        EOF
      end
  end




end
