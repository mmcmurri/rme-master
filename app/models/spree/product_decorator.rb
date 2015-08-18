Spree::Product.class_eval do
  #self.per_page = 10 #for will_paginate

  def brand_name
    brand_name = Spree.t("brand_not_found")
    brand = Spree::Property.find_by(name:"Brand")
    if brand.present?
      if self.product_properties.exists?(brand)
        obj = self.product_properties.find(brand)
        brand_name = obj.value if obj.present?
      else
        obj = self.taxons.find_by(taxonomy:brand)
        brand_name = obj.name if obj.present?
      end
    end
    # puts brand_name
    return brand_name
  end

end