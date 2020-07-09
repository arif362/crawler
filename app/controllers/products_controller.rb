class ProductsController < ApplicationController

  def index
    @products = Product.all
  end

  def search
    Product.scrap_data
    redirect_to root_path
  end

end
