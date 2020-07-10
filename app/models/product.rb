class Product < ApplicationRecord
  # Validations
  validates_presence_of :name, :price, :sku
  validates_uniqueness_of :sku
end
