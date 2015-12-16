class UberHelpers
  def self.available?
    $uber && $uber_lat && $uber_lon
  end

  def get_products
    $uber.products(latitude: $uber_lat, longitude: $uber_lon)
  end

  def get_product_by_name(product_name)
    products = get_products

    products.find {|p| p.display_name.try(:casecmp, product_name) == 0}
  end


  def get_price_estimate(start_lat, start_lon, end_lat, end_lon)
    $uber.price_estimations(start_latitude: start_lat, start_longitude: start_lon,
                         end_latitude: end_lat, end_longitude: end_lon)
  end

  def get_product_estimate(product_name, start_lat, start_lon, end_lat, end_lon)
    estimates = get_price_estimate( start_lat, start_lon, end_lat, end_lon)

    estimates.find {|e| e.display_name.try(:casecmp, product_name) == 0}
  end
end