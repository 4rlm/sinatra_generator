# require_relative 'file_migrator'
require_relative 'file_writer'
require 'active_support/all'
require 'pry'

class AppGenerator
  extend ActiveSupport::Concern

  def initialize
    @app_name = nil
    @mvc = []
  end

  #####################

  def starter
    prompt
    unzip_files
  end

  def prompt
    puts "\nAnswer Questions below in the following format:\n-snake_case\n-singular form\n-separated by space 'if multiple strings'.\n\nEx ~\nApp Name: city_app\nMVC: member city_guide article\n\n"

    puts "App Name:"
    @app_name = gets.chomp
    generate_app
    puts "\n> Successfully generated #{@app_name} directory"

    puts "\n2) MVC:"
    mvc_string = gets.chomp
    @mvc = mvc_string.downcase.split(' ')
    generate_models
    generate_controllers
    # generate_views
    puts "Successfully generated Models, Views & Controllers for: #{@mvc}"

  end

  def generate_app
    FileUtils.mkdir_p("../#{@app_name}/app/controllers")
    FileUtils.mkdir_p("../#{@app_name}/app/helpers")
    FileUtils.mkdir_p("../#{@app_name}/app/models")
    FileUtils.mkdir_p("../#{@app_name}/app/views")
    FileUtils.mkdir_p("../#{@app_name}/config")
    FileUtils.mkdir_p("../#{@app_name}/db/migrate")
    FileUtils.mkdir_p("../#{@app_name}/db/seeds")
    FileUtils.mkdir_p("../#{@app_name}/public/css")
    FileUtils.mkdir_p("../#{@app_name}/public/fonts")
    FileUtils.mkdir_p("../#{@app_name}/public/js")
    FileUtils.mkdir_p("../#{@app_name}/spec")
  end

  def generate_models
    @mvc.each do |snake_case|
      path = "models/#{snake_case}.rb"
      content = FileWriter.make_model_content(snake_case.camelize)
      create_file(path, content)
    end
  end

  # application_controller.rb

  def generate_controllers ####### HERE !!!!!!!!!!!
    # controller_names = @mvc
    # controller_names << 'application'

    @mvc.each do |snake_case|
      path = "controllers/#{snake_case}_controller.rb"
      content = FileWriter.make_controller_content(snake_case.camelize)
      create_file(path, content)
    end
  end

  def generate_views
    # content = "class #{camelized} < ActiveRecord::Base\n\n\nend"
    # path = "./cool_appppp/app/views/#{snake_case}.rb"
    # create_file(path, content)
  end

  def create_file(path, content)
    File.open("../#{@app_name}/app/#{path}", "w+") { |file| file.write(content) }
  end

  def unzip_files
    unzip_file_paths = %w(
      app/controllers/application.rb
      app/controllers/index.rb
      app/views/index.erb
      app/views/layout.erb
      config/database.rb
      config/environment.rb
      public/css/application.css
      public/css/bootstrap.min.css
      public/css/normalize.css
      public/css/style.css
      public/fonts/glyphicons-halflings-regular.eot
      public/fonts/glyphicons-halflings-regular.svg
      public/fonts/glyphicons-halflings-regular.ttf
      public/fonts/glyphicons-halflings-regular.woff
      public/fonts/glyphicons-halflings-regular.woff2
      public/js/application.js
      public/js/bootstrap.min.js
      public/js/jquery.js
      config.ru
      Gemfile
      Rakefile
      x_notes_crud_demo.txt
      x_setup_tips.txt)

    unzip_file_paths.each do |file_path|
      src = "zip_out/#{file_path}"
      dest = "../#{@app_name}/#{file_path}"
      FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.cp(src, dest)
    end

  end


end

new_app = AppGenerator.new
new_app.starter
# new_app.unzip_files
