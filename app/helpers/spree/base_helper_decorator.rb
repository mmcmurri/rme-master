Spree::BaseHelper.class_eval do

  def display_price_level(product_or_variant)
    price_level = "n/a" # Spree.t("no_price_level")
    product_price = product_or_variant.price.to_i
    @prices = Spree::Price.get_price_levels()
    if @prices.present? and @prices.any?
      @prices.each do |price|
        if price[:min] <= product_price && product_price < price[:max]
          price_level = price[:name]
        end
      end
    end
    return price_level
  end

end

