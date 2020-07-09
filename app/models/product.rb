class Product < ApplicationRecord
  require 'nokogiri'
  require 'open-uri'

  # Constants which pages you want to scrap data
  INITIAL_URL = 'https://magento-test.finology.com.my/breathe-easy-tank.html'.freeze

  # Validations
  validates_presence_of :name, :price
  validates_uniqueness_of :name

  # Methods
  def self.scrap_data
    page = Nokogiri::HTML.parse(URI.open(INITIAL_URL))
    # Process scraping data
    product_name, product_price, description, extra_information = process_data(page)
    return unless product_name.present? && product_price.present?

    # Output to the console
    output_log = build_console_data(product_name, product_price, description, extra_information)
    Rails.logger.info output_log

    # Save to Database
    store_to_db(product_name, product_price, description, extra_information)
  end

  def self.process_data(page)
    product_name = page.css('h1.page-title').text
    product_price = page.css('.product-info-price span.price-wrapper').text
    description = page.css('.product.attribute.description div.value').text
    information_rows = page.css('div.additional-attributes-wrapper table tbody tr')
    table_information = []
    information_rows.each do |table_row|
      table_information << "#{table_row.css('th').text}: #{table_row.css('td').text}"
    end

    [product_name, product_price, description, table_information.join(' | ')]
  end

  def self.store_to_db(product_name, product_price, description, extra_information)
    product = find_by(name: product_name)
    return if product.present?

    create!(name: product_name,
            price: product_price,
            description: description,
            extra_information: extra_information)
  end

  def self.build_console_data(product_name, product_price, description, extra_information)
    "<<<<<<<<<<<<<<<<<<<< Target Product Log >>>>>>>>>>>>>>>>>>\n" \
      "\nName: #{product_name.squish.gsub("\n", '')}" \
      "\nPrice: #{product_price.squish.gsub("\n", '')}" \
      "\nDescription: #{description.squish}" \
      "\nExtra Information: #{extra_information.squish.gsub("\n", '')}" \
      "\n\n<<<<<<<<<<<<<<<<<<<< Target Product end >>>>>>>>>>>>>>>>>>>"
  end
end
