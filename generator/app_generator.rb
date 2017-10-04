require_relative 'file_writer'
# require_relative 'zipper'
require 'active_support/all'
require 'pry'

class AppGenerator
  include FileWriter
  # include Zipper
  extend ActiveSupport::Concern

  def initialize
    @app_name = nil
    @mvc = []
    @mvc_hashes = []
  end

  def starter
    prompt
    unzip_files
    generate_brains
    # zip_it
    # zip(dir, zip_dir, remove_after = false)
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
    FileUtils.mkdir_p("../#{@app_name}/public/assets/css")
    FileUtils.mkdir_p("../#{@app_name}/public/assets/fonts")
    FileUtils.mkdir_p("../#{@app_name}/public/assets/img")
    FileUtils.mkdir_p("../#{@app_name}/public/assets/js")
    FileUtils.mkdir_p("../#{@app_name}/spec")
    FileUtils.mkdir_p("../#{@app_name}/x_setup")
  end

  def generate_mvch
    @mvc.each do |snake_case|
      generate_controller_file(snake_case, snake_case.camelize)
      generate_model_file(snake_case, snake_case.camelize)
      generate_migration_file(snake_case, snake_case.camelize)
      generate_helper_file(snake_case, snake_case.camelize)
      # generate_view_file(snake_case, snake_case.camelize)
    end
  end

  def generate_brains
    # app/controllers/application_controller.rb
    # generate_application_controller
    # app/views/index.erb
    # generate_application_index_view
    # app/views/layout.erb
    # generate_application_layout_view
    # config.ru
    generate_config_ru
  end

  # def create_file(path, content)
  #   File.open("../#{@app_name}/app/#{path}", "w+") { |file| file.write(content) }
  # end

  def unzip_files

    unzip_file_paths = %w(
      app/controllers/application_controller.rb
      app/views/index.erb
      app/views/layout.erb
      config/environment.rb
      public/assets/bootstrap/css/bootstrap-theme.css
      public/assets/bootstrap/css/bootstrap-theme.css.map
      public/assets/bootstrap/css/bootstrap-theme.min.css
      public/assets/bootstrap/css/bootstrap.css
      public/assets/bootstrap/css/bootstrap.css.map
      public/assets/bootstrap/css/bootstrap.min.css
      public/assets/bootstrap/fonts/glyphicons-halflings-regular.eot
      public/assets/bootstrap/fonts/glyphicons-halflings-regular.svg
      public/assets/bootstrap/fonts/glyphicons-halflings-regular.ttf
      public/assets/bootstrap/fonts/glyphicons-halflings-regular.woff
      public/assets/bootstrap/fonts/glyphicons-halflings-regular.woff2
      public/assets/bootstrap/js/bootstrap.js
      public/assets/bootstrap/js/bootstrap.min.js
      public/assets/bootstrap/js/npm.js
      public/assets/css/form-elements.css
      public/assets/css/style.css
      public/assets/font-awesome/css/font-awesome.css
      public/assets/font-awesome/css/font-awesome.min.css
      public/assets/font-awesome/fonts/fontawesome-webfont.eot
      public/assets/font-awesome/fonts/fontawesome-webfont.svg
      public/assets/font-awesome/fonts/fontawesome-webfont.ttf
      public/assets/font-awesome/fonts/fontawesome-webfont.woff
      public/assets/font-awesome/fonts/fontawesome-webfont.woff2
      public/assets/font-awesome/fonts/FontAwesome.otf
      public/assets/font-awesome/HELP-US-OUT.txt
      public/assets/font-awesome/less/animated.less
      public/assets/font-awesome/less/bordered-pulled.less
      public/assets/font-awesome/less/core.less
      public/assets/font-awesome/less/fixed-width.less
      public/assets/font-awesome/less/font-awesome.less
      public/assets/font-awesome/less/icons.less
      public/assets/font-awesome/less/larger.less
      public/assets/font-awesome/less/list.less
      public/assets/font-awesome/less/mixins.less
      public/assets/font-awesome/less/path.less
      public/assets/font-awesome/less/rotated-flipped.less
      public/assets/font-awesome/less/stacked.less
      public/assets/font-awesome/less/variables.less
      public/assets/font-awesome/scss/_animated.scss
      public/assets/font-awesome/scss/_bordered-pulled.scss
      public/assets/font-awesome/scss/_core.scss
      public/assets/font-awesome/scss/_fixed-width.scss
      public/assets/font-awesome/scss/font-awesome.scss
      public/assets/font-awesome/scss/_icons.scss
      public/assets/font-awesome/scss/_larger.scss
      public/assets/font-awesome/scss/_list.scss
      public/assets/font-awesome/scss/_mixins.scss
      public/assets/font-awesome/scss/_path.scss
      public/assets/font-awesome/scss/_rotated-flipped.scss
      public/assets/font-awesome/scss/_stacked.scss
      public/assets/font-awesome/scss/_variables.scss
      public/assets/font-awesome/scss/font-awesome.scss
      public/assets/img/backgrounds/1.jpg
      public/assets/js/jquery-1.11.1.js
      public/assets/js/jquery-1.11.1.min.js
      public/assets/js/jquery.backstretch.min.js
      public/assets/js/placeholder.js
      public/assets/js/scripts.js
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
