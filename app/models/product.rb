class Product < ApplicationRecord
  require 'nokogiri'
  require 'open-uri'

  # Constants which pages you want to scrap data
  PAGE_URLS = [
    'https://magento-test.finology.com.my/breathe-easy-tank.html'
  ].freeze

  # Validations
  validates_presence_of :name, :price
  validates_uniqueness_of :name

  # Methods
  def self.scrap_data
    PAGE_URLS.each do |url|
      page = Nokogiri::HTML.parse(URI.open(url))
      product_name = page.css('h1.page-title').text
      product_price = page.css('span.price-wrapper').text.first + page.css('span.price-wrapper').text.split('$')[1]
      description = page.css('div.value').text
      extra_information = page.css('div.additional-attributes-wrapper').text

      # Output to the console
      print_to_console(product_name, product_price, description, extra_information)

      if product_name.present? && product_price.present?
        product = find_by(name: product_name)
        create!(name: product_name, price: product_price, description: description, extra_information: extra_information) unless product.present?
      end
    end
  end

  def self.print_to_console(product_name, product_price, description, extra_information)
    Rails.logger.info "\n<<<<<<<<<<<<<<<<<<<< Target  Product Log >>>>>>>>>>>>>>>>>>>\n"
    Rails.logger.info "Product Name : #{product_name}".squish.gsub("\n", '')
    Rails.logger.info "Product Price : #{product_price}".squish.gsub("\n", '')
    Rails.logger.info "Description : #{description}".squish
    Rails.logger.info "Extra Information : #{extra_information}".squish.gsub("\n", '')
    Rails.logger.info "\n<<<<<<<<<<<<<<<<<<<< Log End  >>>>>>>>>>>>>>>>>>>\n"
  end

end
