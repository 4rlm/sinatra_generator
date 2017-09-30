# example_controller.rb
class ExampleController < ApplicationController
  get '/' do
    'Example!'
    erb :'index'
  end
  
end
