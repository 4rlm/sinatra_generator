require 'active_support/all'
require 'pry'

module FileWriter
  extend ActiveSupport::Concern

  def self.make_model_content(camelized)
    "class #{camelized} < ActiveRecord::Base\n\nend"
  end

  def self.make_controller_content(snake_case, camelized)
    "class #{camelized}Controller < Sinatra::Base\nget '/#{snake_case}' do\n'On #{camelized} page.'\n# erb :'index'\nend\n\nend"
  end

  def self.make_helper_content(camelized)
    "module #{camelized}Helpers\n\nend\nhelpers #{camelized}Helpers"
  end


end
