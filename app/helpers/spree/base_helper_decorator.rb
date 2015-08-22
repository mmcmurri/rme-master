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

  def display_brand_name(product_or_variant)
    product = product_or_variant.product if product_or_variant.instance_of?(Spree::Variant)
    product = product_or_variant if product_or_variant.instance_of?(Spree::Product)
    brand_name = Spree.t("brand_not_found")
    if Spree::Property.exists?(name: "Brand") #finding in properties
      brand = Spree::Property.find_by(name: "Brand")
      if product.product_properties.exists?(property_id: brand.id)
        obj = product.product_properties.find_by(property_id: brand.id)
        brand_name = obj.value if obj.present?
      elsif Spree::Taxonomy.exists?(name: "Brand") #finding in taxonomies
        brand = Spree::Taxonomy.find_by(name: "Brand")
        obj = product.taxons.find_by(taxonomy: brand)
        brand_name = obj.name if obj.present?
      end
    end
    # puts brand_name
    return brand_name
  end

end

