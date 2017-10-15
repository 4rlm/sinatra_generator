require 'active_support/all'
require 'pry'

module FileWriter
  extend ActiveSupport::Concern


  def snake_to_cap_string(snake_case)
    snake_case = snake_case.downcase.tr("_", " ") if snake_case.include?('_')
    capitalized_strings = snake_case.split.map(&:capitalize).join(' ')
  end

  def field_extractor(snake_case)
    raw_fields = @mvc_hashes.find { |hash| hash[:table] == snake_case }[:fields]
    fields = raw_fields.map { |field_pair| field_pair.split(':').first }
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
      require 'will_paginate/active_record'

      class ApplicationController < Sinatra::Base
        include ApplicationHelper
        include WillPaginate::Sinatra::Helpers

        configure do
          set :public_folder, 'public'
          set :views, 'app/views'
          enable :sessions
          set :session_secret, "password_security"
        end

        before do
          @alert_msg = {}
          logged_in
        end

        get '/' do
          @alert_msg[:success_alert] = "Success test alert ..."
          @alert_msg[:danger_alert] = "Danger test alert ..."

          # !logged_in ? (redirect 'users/login') : redirect_to_home_page

          # # if !logged_in
          # #   redirect 'users/login'
          # # else
          #   @channels = Channel.all.order("updated_at DESC").paginate(page: params[:page], per_page: 10)
          #   redirect_to_home_page
          # # end

        end

      #{route_strings}

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

          # before "/#{snake_plural}/*" do
          #   if !request.post?
          #     if !logged_in
          #       @alert_msg[:danger_alert] = "Please login to choose new #{snake_plural}."
          #       erb :'users/login'
          #     end
          #   end
          # end

          # INDEX: #{snake_plural} view all.
          get '/#{snake_plural}' do
            @#{snake_plural} = #{camelize}.order('updated_at ASC').limit(10)
            # @#{snake_plural} = #{camelize}.all.order('updated_at DESC').paginate(page: params[:page], per_page: 5)
            erb :'#{snake_plural}/index'
          end

          # NEW: #{snake_plural} new
          get '/#{snake_plural}/new' do

            if !logged_in
              @alert_msg[:danger_alert] = "Please login to choose new #{camelize}."
              erb :'users/login'
            else
              @#{snake_case} = #{camelize}.new  ## Prevents errors on Form Partial.
              erb :'#{snake_plural}/new'
            end

          end


          # CREATE:
          post '/#{snake_plural}' do
            @#{snake_case} = #{camelize}.create(params[:#{snake_case}])
            redirect '/#{snake_plural}'
          end

          # SHOW: displays a single #{snake_case} detail page.
          get '/#{snake_plural}/:id' do
            @#{snake_case} = #{camelize}.find(params[:id])
            erb :'#{snake_plural}/show'
          end

          # EDIT:
          get '/#{snake_plural}/:id/edit' do
            @#{snake_case} = #{camelize}.find(params[:id])
            erb :'#{snake_plural}/edit'
          end

          ##### Update Method (patch or put) ####

          # UPDATE: Method for patch and put
          def update_#{snake_case}
            @#{snake_case} = #{camelize}.find(params[:id])
            @#{snake_case}.update(params[:#{snake_case}])
            redirect "/#{snake_plural}/#\{@#{snake_case}.id}"
          end

          # UPDATE: patch
          patch '/#{snake_plural}/:id' do
            update_#{snake_case}
          end

          # UPDATE: put
          put '/#{snake_plural}/:id' do
            update_#{snake_case}
          end

          #################################

          # DELETE:
          delete '/#{snake_plural}/:id' do
            #{camelize}.find(params[:id]).destroy!
            redirect '/#{snake_plural}'
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
      use UsersController
      run ApplicationController

      EOF
    end
  end




  ###### GENERATE VIEWS FILES BELOW ######

  def generate_view_files(snake_case, camelized)
    snake_plural = snake_case.pluralize
    # fields = @mvc_hashes.find { |hash| hash[:table] == snake_case }[:fields]
    fields = field_extractor(snake_case)

    FileUtils.mkdir_p("../#{@app_name}/app/views/#{snake_plural}")
    generate_index_view(snake_case, camelized, snake_plural, fields)
    generate_show_view(snake_case, camelized, snake_plural, fields)
    generate_form_fields(snake_case, camelized, snake_plural, fields)
    generate_new_view(snake_case, camelized, snake_plural)
    generate_edit_view(snake_case, camelized, snake_plural)
    generate_delete_view(snake_case, camelized, snake_plural)
  end


  def generate_form_fields(snake_case, camelized, snake_plural, fields)
    form_path = "../#{@app_name}/app/views/#{snake_plural}/_form_fields.erb"
    puts "Creating #{form_path}"

    html_block = []
    fields.each do |field|
      html_block << (<<-EOF.gsub(/^ {6}/, ''))
      <div class="form-group">
        <label for="#{field}" class="col-sm-2 control-label">#{snake_to_cap_string(field)}</label>
        <div class="col-sm-10">
          <input class="form-control" id="#{field}" name="#{snake_case}[#{field}]" type="text" value="<%= @#{snake_case}.#{field} %>" placeholder="#{snake_to_cap_string(field)}" />
        </div>
      </div>

      EOF
    end

    html_block_string = html_block.join("")
    File.open(form_path, 'w+') do |f|
      f.write(<<-EOF.gsub(/^ {6}/, ''))
      <!-- # Duplicate info from new.erb and edit.erb forms goes in this partial. -->

      #{html_block_string}

      EOF
    end
  end

  def generate_new_view(snake_case, camelized, snake_plural)
    view_path = "../#{@app_name}/app/views/#{snake_plural}/new.erb"
    puts "Creating #{view_path}"

    File.open(view_path, 'w+') do |f|
      f.write(<<-EOF.gsub(/^ {6}/, ''))
      <div class="">

        <div class="erb_header">
          <h3>Create New #{snake_to_cap_string(snake_case)}</h3>
        </div>

        <form class="form-horizontal" action="/#{snake_plural}" method="post">

          <!-- ## Form content moved to partial (_form_fields.erb) -->
          <%= erb :'#{snake_plural}/_form_fields'%>

          <button class="btn btn-success" name="commit" type="submit">Submit New #{camelized}</button>
        </form>

      </div>

      EOF
    end
  end

  def generate_edit_view(snake_case, camelized, snake_plural)
    view_path = "../#{@app_name}/app/views/#{snake_plural}/edit.erb"
    puts "Creating #{view_path}"

    File.open(view_path, 'w+') do |f|
      f.write(<<-EOF.gsub(/^ {6}/, ''))
      <div class="">

        <div class="erb_header">
          <h3>Edit #{snake_to_cap_string(snake_case)}</h3>
        </div>

        <form class="form-horizontal" action="/#{snake_plural}/<%= @#{snake_case}.id %>" method="post">

          <div class="form-group">
            <input class="form-control" name="_method" type="hidden" value="patch" />
          </div>

          <!-- ## Form content moved to partial (_form_fields.erb) -->
          <%= erb :'#{snake_plural}/_form_fields', layout: false %>

          <button class="btn btn-success" name="commit" type="submit">Update #{camelized}</button>
        </form>

      </div>
      EOF
    end

  end

  def generate_show_view(snake_case, camelized, snake_plural, fields)
    view_path = "../#{@app_name}/app/views/#{snake_plural}/show.erb"
    puts "Creating #{view_path}"

    th_blocks = []
    fields.each do |field|
      th_blocks << (<<-EOF.gsub(/^ {6}/, ''))
      <th class="w-small">#{snake_to_cap_string(field)}</th>
      EOF
    end

    td_blocks = []
    fields.each do |field|
      td_blocks << (<<-EOF.gsub(/^ {6}/, ''))
      <td><%= @#{snake_case}.#{field} %></td>
      EOF
    end

    th_block_strings = th_blocks.join('')
    td_block_strings = td_blocks.join('')

    File.open(view_path, 'w+') do |f|
      f.write(<<-EOF.gsub(/^ {6}/, ''))
      <div class="">

        <div class="erb_header">
          <h3>#{snake_to_cap_string(snake_case)} Detail View</h3>
        </div>

        <table class="table table-bordered table-hover table-striped text-nowrap">
          <tr>
            <th class="w-small">ID</th>
      #{th_block_strings}
            <th class="w-med">Updated</th>
          </tr>

          <tr>
            <td><%= @#{snake_case}.id %></td>
      #{td_block_strings}
            <td><%= @#{snake_case}.updated_at.strftime('%x')%></td>
          </tr>

        </table>
      </div>
      EOF
    end
  end

  def generate_index_view(snake_case, camelized, snake_plural, fields)
    view_path = "../#{@app_name}/app/views/#{snake_plural}/index.erb"
    puts "Creating #{view_path}"

    th_blocks = []
    fields.each do |field|
      th_blocks << (<<-EOF.gsub(/^ {6}/, ''))
      <th>#{snake_to_cap_string(field)}</th>
      EOF
    end

    td_blocks = []
    fields.each do |field|
      td_blocks << (<<-EOF.gsub(/^ {6}/, ''))
      <td><%= #{snake_case}.#{field} %></td>
      EOF
    end

    th_block_strings = th_blocks.join('')
    td_block_strings = td_blocks.join('')

    File.open(view_path, 'w+') do |f|
      f.write(<<-EOF.gsub(/^ {6}/, ''))
      <h3>View All #{snake_to_cap_string(snake_case)}</h3>

      <table class="table table-bordered table-hover table-striped text-nowrap">
        <tr>
          <th class="w-small">ID</th>
      #{th_block_strings}
          <th class="w-med">Updated</th>
          <th colspan="3" class="w-med">Manage</th>
        </tr>
        <% @#{snake_plural}.each do |#{snake_case}|%>
        <tr>
          <td class="w-small"><%= #{snake_case}.id%></td>
      #{td_block_strings}
          <td><%= #{snake_case}.updated_at.strftime('%x')%></td>

          <td><a href="/#{snake_plural}/<%= #{snake_case}.id %>"><span class="glyphicon glyphicon-folder-open"></span></a></td>
          <td><a href="/#{snake_plural}/<%= #{snake_case}.id %>/edit"><span class="glyphicon glyphicon-edit"></span></a></td>

          <td><%= erb :'#{snake_plural}/_delete', layout: true, locals: { #{snake_case}: #{snake_case} }%></td>

        </tr>
        <% end %>
      </table>


      <div class="digg_pagination">
        <%#= will_paginate @#{snake_plural}, renderer: BootstrapPagination::Sinatra %>
        <%#= will_paginate @#{snake_plural} %>
      </div>

      EOF
    end
  end

  def generate_delete_view(snake_case, camelized, snake_plural)
    view_path = "../#{@app_name}/app/views/#{snake_plural}/_delete.erb"
    puts "Creating #{view_path}"

    File.open(view_path, 'w+') do |f|
      f.write(<<-EOF.strip_heredoc)
      <form action="/#{snake_plural}/<%= #{snake_case}.id %>" method="post">
        <input name="_method" type="hidden" value="delete" />
        <button name="commit" type="submit"><span class="glyphicon glyphicon-trash"></span></button>
      </form>
      EOF
    end
  end

  def generate_application_layout_view
    li_links = []
    @mvc.each do |snake_case|
      snake_plural = snake_case.pluralize
      camelized = snake_case.camelize
      li_links <<  (<<-EOF.gsub(/^ {6}/, ''))
      <li class="dropdown">
        <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">#{camelized} <span class="caret"></span></a>
        <ul class="dropdown-menu">
          <li><a href='/#{snake_plural}'>View #{camelized}</a></li>
          <li><a href='/#{snake_plural}/new'>New #{camelized}</a></li>
        </ul>
      </li>

      EOF
    end

    app_name_string_capitalized = snake_to_cap_string(@app_name)
    li_link_strings = li_links.join("")
    layout_path = "../#{@app_name}/app/views/layout.erb"
    puts "Creating #{layout_path}"

    File.open(layout_path, 'w+') do |f|
      f.write(<<-EOF.gsub(/^ {6}/, ''))
      <!DOCTYPE html>
      <html lang="en">

        <head>

          <meta charset="utf-8">
          <meta http-equiv="X-UA-Compatible" content="IE=edge">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>#{snake_to_cap_string(@app_name)}</title>

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
          <!-- <nav class="navbar navbar-fixed-top"> -->
          <nav class="navbar navbar-inverse navbar-fixed-top">

              <div class="container-fluid">
                <!-- Brand and toggle get grouped for better mobile display -->
                <div class="navbar-header">
                  <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="navbar" aria-expanded="false">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                  </button>
                  <a class="navbar-brand" href="/"><span class="glyphicon glyphicon-list-alt"></span> #{snake_to_cap_string(@app_name)}</a>
                </div>

                <!-- Collect the nav links, forms, and other content for toggling -->
                <div id="navbar" class="collapse navbar-collapse">

                  <ul class="nav navbar-nav">
                  #{li_link_strings}
                  <li><a href='/users/index'>View Members</a></li>
                  </ul>

                  <ul class="nav navbar-nav navbar-right">
                    <% if @user %>
                      <li><a href='/users/logout'>Log Out</a></li>
                      <li><a href="/users/<%= @user.id %>"><%= @user.name.capitalize %></a></li>
                    <% else %>
                      <li><a href='/users/register'>Register</a></li>
                      <li><a href='/users/login'>Login</a></li>
                    <% end %>
                  </ul>

                </div><!-- /.navbar-collapse -->
              </div><!-- /.container-fluid -->
            </nav>
          </div>

          <div class='container erb-wrapper text-center' id='main'>

            <% @alert_msg.keys.each do |type| %>
              <div class="alert <%= type %>" role="alert">
                <%= @alert_msg[type] %>
              </div>
            <% end %>

            <%= yield %>
          </div>

          <!-- Footer -->
          <div class="footer text-center">
            <h4>Developed by The Austonites &copy 2017</h4>
          </div>

          <!-- Javascript -->
          <script src="../../../assets/js/jquery-1.11.1.min.js"></script>
          <script src="../../../assets/bootstrap/js/bootstrap.min.js"></script>
          <!-- <script src="../../../assets/js/jquery.backstretch.min.js"></script> -->
          <!-- <script src="../../../assets/js/scripts.js"></script> -->

          <!--[if lt IE 10]>
              <script src="assets/js/placeholder.js"></script>
          <![endif]-->

        </body>

      </html>

      EOF
    end
  end

  def generate_seed
    seed_path = "../#{@app_name}/db/seeds.rb"
    puts "Creating #{seed_path}"
    # tables = @mvc_hashes.map { |hash| hash[:table] }

    # fields = field_extractor(snake_case) # might need to use this.

    seed_model_blocks = []
    @mvc_hashes.each do |table_hash|
      model_name = table_hash[:table]
      fields = table_hash[:fields]
      # binding.pry
      seed_model_blocks << (<<-EOF.gsub(/^ {6}/, ''))

      def seed_#{model_name}_table
        puts "Seeding the #{model_name} table..."
        total_seeds_required = 50
        current_seeds_in_db = #{model_name.camelize}.count
        seeds_to_create = total_seeds_required - current_seeds_in_db

        # #{fields}
        seeds_to_create.times do
          # #{model_name}_hash = {
          #   name: Faker::Lorem.word,
          #   description: Faker::Lorem.sentence,
          #   status: Faker::Lorem.word,
          #   rating: 5
          # }
          new_#{model_name}_record = #{model_name.camelize}.new(#{model_name}_hash)
          new_#{model_name}_record.save!
        end

      end
      seed_#{model_name}_table

      EOF
    end

    seed_model_block_strings = seed_model_blocks.join('')
    File.open(seed_path, 'w+') do |f|
      f.write(<<-EOF.gsub(/^ {6}/, ''))
      puts "Seeding the database ..."

      #{seed_model_block_strings}
      EOF
    end
  end






end
