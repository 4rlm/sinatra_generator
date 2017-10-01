require 'active_support/all'
require 'pry'

module FileWriter
  extend ActiveSupport::Concern

  def generate_model_file(snake_case, model_name)
    model_path = "../#{@app_name}/app/models/#{snake_case}.rb"
    puts "Creating #{model_path}"

    File.open(model_path, 'w+') do |f|
      f.write(<<-EOF.strip_heredoc)
        class #{model_name} < ApplicationRecord
          # Remember to create a migration!
        end
      EOF
    end
  end


  def generate_migration_file(snake_case, migration_name)
    snake_plural = snake_case.pluralize
    camel_plural = migration_name.pluralize
    filename = "#{Time.now.strftime('%Y%m%d%H%M%S')}_create_#{snake_plural}"
    migration_path = "../#{@app_name}/db/migrate/#{filename}.rb"
    puts "Creating #{migration_path}"

    File.open(migration_path, 'w+') do |f|
      f.write(<<-EOF.strip_heredoc)
        class Create#{camel_plural} < ActiveRecord::Migration
          def change
            create_table :#{snake_plural} do |t|

              t.timestamps
            end
          end
        end
      EOF
    end
  end


  # def generate_controller_file(snake_case, helper_name)
  #   helper_path = "../#{@app_name}/app/helpers/#{snake_case}.rb"
  #   puts "Creating #{helper_path}"
  #
  #   File.open(helper_path, 'w+') do |f|
  #     f.write(<<-EOF.strip_heredoc)
  #       class #{helper_name} < ApplicationRecord
  #         # Remember to create a migration!
  #       end
  #     EOF
  #   end
  #
  # end



  # def generate_helper_file(snake_case, controller_name)
  #   controller_path = "../#{@app_name}/app/controllers/#{snake_case}.rb"
  #   puts "Creating #{controller_path}"
  #
  #   File.open(controller_path, 'w+') do |f|
  #     f.write(<<-EOF.strip_heredoc)
  #       class #{controller_name} < ApplicationRecord
  #         # Remember to create a migration!
  #       end
  #     EOF
  #   end
  #
  # end


  # def generate_view_file(snake_case, view_name)
  #   view_path = "../#{@app_name}/app/views/#{snake_case}.rb"
  #   puts "Creating #{view_path}"
  #
  #   File.open(view_path, 'w+') do |f|
  #     f.write(<<-EOF.strip_heredoc)
  #       class #{view_name} < ApplicationRecord
  #         # Remember to create a migration!
  #       end
  #     EOF
  #   end
  #
  # end


  # def make_controller_content(snake_case, camelized)
  #   "class #{camelized}Controller < Sinatra::Base\nget '/#{snake_case}' do\n'On #{camelized} page.'\n# erb :'index'\nend\n\nend"
  # end
  #
  # def make_helper_content(camelized)
  #   "module #{camelized}Helpers\n\nend\nhelpers #{camelized}Helpers"
  # end


end
