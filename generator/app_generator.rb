require_relative 'file_writer'
require 'active_support/all'
require 'pry'

class AppGenerator
  include FileWriter
  extend ActiveSupport::Concern

  def initialize
    @app_name = nil
    @mvc = []
    @mvc_hashes = []
  end

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


    puts "\n3) Migration Files:\nEnter field name and type in following format:\nfirst_name, last_name, phone:integer, current:boolean, birthday:date\nDefault datatype will be string if not specified.\n\n"
    get_migration_data_fields

    #############################
    generate_mvch
    puts "Testing - Complete."
    puts "Successfully generated Models, Views & Controllers for: #{@mvc}"

  end

  def get_migration_data_fields
    @mvc.each do |table|
      puts "#{table}:"
      data_fields_string = gets.chomp
      data_fields_array = data_fields_string.split(", ")
      @mvc_hashes << { table: table, fields: data_fields_array }
    end
  end


  def generate_app
    FileUtils.mkdir_p("../#{@app_name}/app/controllers")
    FileUtils.mkdir_p("../#{@app_name}/app/helpers")
    FileUtils.mkdir_p("../#{@app_name}/app/models")
    FileUtils.mkdir_p("../#{@app_name}/app/views")
    FileUtils.mkdir_p("../#{@app_name}/config")
    FileUtils.mkdir_p("../#{@app_name}/db/migrate")
    FileUtils.mkdir_p("../#{@app_name}/db/seeds")
    FileUtils.mkdir_p("../#{@app_name}/lib")
    FileUtils.mkdir_p("../#{@app_name}/public/css")
    FileUtils.mkdir_p("../#{@app_name}/public/fonts")
    FileUtils.mkdir_p("../#{@app_name}/public/img")
    FileUtils.mkdir_p("../#{@app_name}/public/js")
    FileUtils.mkdir_p("../#{@app_name}/spec")
    FileUtils.mkdir_p("../#{@app_name}/x_setup")
  end

  def generate_mvch
    @mvc.each do |snake_case|
      generate_controller_file(snake_case, snake_case.camelize)
      generate_model_file(snake_case, snake_case.camelize)
      generate_migration_file(snake_case, snake_case.camelize)
      # generate_view_file(snake_case, snake_case.camelize)
      generate_helper_file(snake_case, snake_case.camelize)
    end
  end

  # def create_file(path, content)
  #   File.open("../#{@app_name}/app/#{path}", "w+") { |file| file.write(content) }
  # end

  def unzip_files

    unzip_file_paths = %w(
      app/controllers/application_controller.rb
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
      public/favicon.ico
      config.ru
      Gemfile
      Rakefile
      x_setup/x_many_to_many.rb
      x_setup/x_notes_crud_demo.txt
      x_setup/x_steps.txt
      x_setup/x_setup_tips.txt)

    unzip_file_paths.each do |file_path|
      src = "zip_out/#{file_path}"
      dest = "../#{@app_name}/#{file_path}"
      FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.cp(src, dest)
    end

  end

end
