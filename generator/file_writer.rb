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

  def generate_helper_file(snake_case, helper_name)
    helper_path = "../#{@app_name}/app/helpers/#{snake_case}.rb"
    puts "Creating #{helper_path}"

    File.open(helper_path, 'w+') do |f|
      f.write(<<-EOF.strip_heredoc)
        module #{helper_name}Helper

          def greeting
            puts "In the #{helper_name}Helper module."
          end

        end
        helpers #{helper_name}Helper
      EOF
    end
  end

  def generate_controller_file(snake_case, controller_name)
    controller_path = "../#{@app_name}/app/controllers/#{snake_case}.rb"
    puts "Creating #{controller_path}"

    File.open(controller_path, 'w+') do |f|
      f.write(<<-EOF.strip_heredoc)
        class #{controller_name}Controller < ApplicationController

          get '/#{snake_case}' do
            '#{snake_case}'
            erb :'index'
          end

        end

      EOF
    end

  end

  def generate_application_controller
    @mvc
    # app/controllers/application_controller.rb
  end

  def generate_application_index_view
    @mvc
    # app/views/index.erb
  end

  def generate_application_layout_view
    @mvc
    # app/views/layout.erb
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



end
