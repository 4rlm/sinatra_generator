require 'active_support/all'
require 'pry'

module FileContent
  extend ActiveSupport::Concern

  def self.make_model_content(camelized)
    "class #{camelized} < ActiveRecord::Base\n\n\nend"
  end

  def self.make_controller_content(camelized)
    "class #{camelized} < ActiveRecord::Base\n\n\nend"
  end


end
