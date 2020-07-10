class ProductsController < ApplicationController
  before_action :authenticate_user!

  def index
    @products = Product.paginate(page: params[:page], per_page: 10).order('id DESC')
  end

  def search
    url = params[:page_url].present? ? params[:page_url] : 'https://magento-test.finology.com.my/breathe-easy-tank.html'
    if Product.valid_url?(url)
      Product.scrap_data(url)
      redirect_to root_path
    else
      redirect_to root_path, notice: 'Url not valid; Please use a valid url from your reference site'
    end
  end
end
