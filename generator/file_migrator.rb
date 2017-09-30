require 'active_support/all'
# require 'fileutils'
require 'pry'

module FileMigrator
  extend ActiveSupport::Concern

  def self.unzip_files
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
