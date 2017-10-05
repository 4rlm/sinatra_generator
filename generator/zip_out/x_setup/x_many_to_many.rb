######################################
# For Reference Only - Not Part of App
######################################

=begin

### Models ###
class User
  has_many :purchases
  has_many :products, through: :purchases
end

class Product
  has_many :purchases
  has_many :users, through: :purchases
end

class Purchase
  belongs_to :user
  belongs_to :product
end

### Migrations ####

class CreatePurchases < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.timestamps
    end

    create_table :products do |t|
      t.string :name
      t.timestamps
    end

    create_table :purchases do |t|
      t.belongs_to :user, index: true
      t.belongs_to :product, index: true
      t.timestamps
    end
  end
end


####################
=end
