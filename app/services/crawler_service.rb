class CrawlerService
  require 'nokogiri'
  require 'open-uri'

  # Methods
  def self.scrap_data(url)
    url_list = page_urls(url) if UrlValidationService.valid_url?(url)
    return ['Something went wrong, Please try another url', ''] if url_list.nil?

    scrapping_products = []
    url_list.each do |target_url|
      Rails.cache.fetch("target_url_#{target_url}", expires_in: 12.hours) do
        scrap_from_url(target_url, scrapping_products) if UrlValidationService.valid_url?(target_url)
      end
    end
    result(scrapping_products)
  end

  def self.result(scrapping_products)
    ["#{scrapping_products.empty? ? 'May be scrapping done previously that' : 'Data scrapping successful for '}
     #{scrapping_products.empty? ? '' : scrapping_products.length} products !",
     scrapping_products]
  end

  private

  def self.scrap_from_url(url, scrapping_products)
    page = Nokogiri::HTML.parse(URI.open(url))
    # Process scraping data
    product_name, product_price, description, sku, extra_information = process_data(page)
    return unless sku.present? && product_name.present?

    product = Product.find_by(sku: sku)
    return if product.present?

    # Output to the console
    OutputConsoleService.build_console_data(product_name, product_price, description, extra_information)

    # Save to Database
    product = Product.new(name: product_name, price: product_price, description: description, sku: sku,
                          extra_information: extra_information)
    scrapping_products << product if product.save
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

end
