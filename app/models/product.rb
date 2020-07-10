class Product < ApplicationRecord
  require 'nokogiri'
  require 'open-uri'

  # Validations
  validates_presence_of :name, :price, :sku
  validates_uniqueness_of :sku

  # Methods
  def self.scrap_data(url)
    url_list = page_urls(url)
    return 'Something went wrong, Please try another url' if url_list.nil?

    url_list.each do |target_url|
      Rails.cache.fetch("target_url_#{target_url}", expires_in: 12.hours) do
        scrap_from_url(target_url) if valid_url?(target_url)
      end
    end
    'Data Scrapping successful !!'
  end

  def self.valid_url?(url)
    uri = URI.parse(url)
    uri.is_a?(URI::HTTP) && !uri.host.nil?
  rescue URI::InvalidURIError
    false
  end

  def self.scrap_from_url(url)
    page = Nokogiri::HTML.parse(URI.open(url))
    # Process scraping data
    product_name, product_price, description, sku, extra_information = process_data(page)
    return unless sku.present? && product_name.present?

    product = find_by(sku: sku)
    return if product.present?

    # Output to the console
    output_log = build_console_data(product_name, product_price, description, extra_information)
    Rails.logger.info output_log

    # Save to Database
    store_to_db(product_name, product_price, description, sku, extra_information)
  end

  def self.page_urls(url)
    parsed_url = Nokogiri::HTML.parse(URI.open(url))
    url_list = parsed_url.css('.product-item a').map { |anchor| anchor['href'] }
    url_list << url
    url_list
  rescue StandardError => e
    nil
  end

  def self.process_data(page)
    product_name = page.css('h1.page-title').text
    product_price = page.css('.product-info-price span.price-wrapper').text
    description = page.css('.product.attribute.description div.value').text
    sku = page.css('.product.attribute.sku div.value').text
    information_rows = page.css('div.additional-attributes-wrapper table tbody tr')
    table_information = table_information(information_rows)

    [product_name, product_price, description, sku, table_information]
  end

  def self.table_information(information_rows)
    table_information = []
    information_rows.each do |table_row|
      table_information << "#{table_row.css('th').text}: #{table_row.css('td').text}"
    end
    table_information.join(' | ')
  end

  def self.store_to_db(product_name, product_price, description, sku, extra_information)
    create!(name: product_name,
            price: product_price,
            description: description,
            sku: sku,
            extra_information: extra_information)
  end

  def self.build_console_data(product_name, product_price, description, extra_information)
    "<<<<<<<<<<<<<<<<<<<< Target Product Details Log >>>>>>>>>>>>>>>>>>\n" \
      "\nName: #{product_name.squish.gsub("\n", '')}" \
      "\nPrice: #{product_price.squish.gsub("\n", '')}" \
      "\nDescription: #{description.squish}" \
      "\nExtra Information: #{extra_information.squish.gsub("\n", '')}" \
      "\n\n<<<<<<<<<<<<<<<<<<<< Product Log end >>>>>>>>>>>>>>>>>>>"
  end
end
