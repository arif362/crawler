class ProductsController < ApplicationController
  before_action :authenticate_user!

  def index
    @products = Product.paginate(page: params[:page], per_page: 10).order('id DESC')
  end

  def search
    url = params[:page_url].present? ? params[:page_url] : 'https://magento-test.finology.com.my/breathe-easy-tank.html'
    result = CrawlerService.scrap_data(url)
    @scrapping_products = result.last
    flash[:info] = result.first
  end
end
