class OutputConsoleService
  def self.build_console_data(product_name, product_price, description, extra_information)
    Rails.logger.info "<<<<<<<<<<<<<<<<<<<< Target Product Details Log >>>>>>>>>>>>>>>>>>\n" \
      "\nName: #{product_name.squish.gsub("\n", '')}" \
      "\nPrice: #{product_price.squish.gsub("\n", '')}" \
      "\nDescription: #{description.squish}" \
      "\nExtra Information: #{extra_information.squish.gsub("\n", '')}" \
      "\n\n<<<<<<<<<<<<<<<<<<<< Product Log end >>>>>>>>>>>>>>>>>>>"
  end
end