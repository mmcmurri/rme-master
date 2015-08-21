Spree::HomeController.class_eval do
  before_action :material, :only => [:product_selected, :products_liked]
  protect_from_forgery except: :shops_ajax #fixed Security warning: an embedded <script> tag on another site requested protected JavaScript. If you know what you're doing, go ahead and disable forgery protection on this action to permit cross-origin JavaScript embedding.

  def index

    colorPropertyName = "Color"
    materialPropertyName = "Material"

    @colors = []
    @materials = []

    propertyColor = Spree::Property.find_by(name: colorPropertyName)
    propertyMaterial = Spree::Property.find_by(name: materialPropertyName)

    materialsFromProperties = Spree::ProductProperty.where(property_id: propertyMaterial)
    colorsFromProperties = Spree::ProductProperty.where(property_id: propertyColor)

    # #TODO: add values (color, material) from option_values to products if variants are required
    # colorOptionType = Spree::OptionType.find_by(presentation: colorPropertyName) if Spree::OptionType.exists?(presentation: colorPropertyName)
    # materialOptionType = Spree::OptionType.find_by(presentation: materialPropertyName) if Spree::OptionType.exists?(presentation: materialPropertyName)
    #
    # colorsFromOptionValues = colorOptionType.option_values if colorOptionType.present? && colorOptionType.option_values.present?
    # materialsFromOptionValues = materialOptionType.option_values if materialOptionType.present? && materialOptionType.option_values.present?
    #
    # colorsFromOptionValues.each { |p| @colors << p.presentation } if colorsFromOptionValues.present?
    # materialsFromOptionValues.each { |p| @materials << p.presentation } if materialsFromOptionValues.present?


    colorsFromProperties.each { |p| @colors << p.value } if colorsFromProperties.present?
    materialsFromProperties.each { |p| @materials << p.value } if materialsFromProperties.present?

    @materials.uniq!
    @colors.uniq!

    @prices = Spree::Price.get_price_levels()
    @taxonomies = Spree::Taxonomy.includes(root: :children)

    ## ajax request handler
    #if request.xhr? # get ajax request or in shops_ajax() method
    #  @product_list = [];
    #  if params["colors"].present?
    #    @colors.each do |color|
    #      color.variants.each do |variant|
    #        @product_list << variant if variant.present? && variant.product.present?
    #      end
    #    end
    #  end
    #  render :json => {
    #      ajax:"ajax", :products => @product_list, searcher:@searcher, taxonomies:@taxonomies, colors:@colors, materials:@materials, prices:@prices
    #  }
    #end
  end

  def shops_ajax
    @errors = []
    page = 1
    page = params[:page] if params[:page].present? && params[:page].to_i > 0

    # products = Spree::Product.page(page)
    # respond_to_and_exit(products)
    # return

    sku = params[:sku]
    arrColors = split_params params[:colors]
    arrMaterials = split_params params[:materials]
    arrCategories = split_params split_params params[:categories]
    arrPrices = params[:prices] if params[:prices].present?

    products = []
    property_material_name = "Material"
    property_color_name = "Color"

    #searching by sku (product code)
    if sku.present?
      variants = Spree::Variant.where(sku: sku.strip.upcase) #.page(page)
      respond_to_and_exit(variants)
      return
    end

    # Search/filtering the products by their brands or/and their categories only.
    if arrCategories.present? && arrColors.blank? && arrMaterials.blank? && arrPrices.blank?
      taxons = Spree::Taxon.where(name: arrCategories)
      products = Spree::Product.in_taxons(taxons).page(page)
    end

    # if only filter.shop_by_price applied
    if arrPrices.present? && arrCategories.blank? && arrColors.blank? && arrMaterials.blank?
      products = filter_products_by_price(Spree::Product.all, arrPrices).page(page)
    end

    # if only filter.shop_by_material applied
    if arrMaterials.present? && arrPrices.blank? && arrCategories.blank? && arrColors.blank?
      productItems = Spree::Product.includes(:product_properties, :properties).where("spree_product_properties.value" => arrMaterials, "spree_properties.name" => property_material_name).uniq.page(page)

      #TODO: add variants from option_values to products if needed
      ## searching in product variants
      # variants = Spree::Variant.includes(:option_values).where("spree_option_values.presentation" => arrMaterials).uniq.page(page) #search products by material in his variants.
      # variants.each { |variant| productMaterials << variant if variant.present? && variant.product.present? } # add variant to products
      products = productItems
    end

    # if only filter.shop_by_color applied
    if arrColors.present? && arrPrices.blank? && arrCategories.blank? && arrMaterials.blank?
      productColors = Spree::Product.includes(:product_properties, :properties).where("spree_product_properties.value" => arrColors, "spree_properties.name" => property_color_name).uniq.page(page)

      #TODO: add variants from option_values to products if needed
      # # searching in product variants
      # variants = Spree::Variant.includes(:option_values).where("spree_option_values.presentation" => arrColors).page(page) #search products by color in his variants.
      # variants.each { |variant| productColors << variant if variant.present? && variant.product.present? } # add variant to products

      products = productColors
    end

    # if only ShopByColor and ShopByMaterial filters are applied together.
    if arrColors.present? && arrMaterials.present? && arrPrices.blank? && arrCategories.blank?
      values = arrMaterials + arrColors
      # products = Spree::Product.includes(:product_properties, :properties) \
      #                .where(spree_product_properties: {value:arrColors}, spree_properties:{name:property_color_name}) \
      #                .where(spree_product_properties: {value:arrMaterials}, spree_properties:{name:property_material_name})

      products = Spree::Product.includes(:product_properties, :properties).where(spree_product_properties: {value:arrColors}, spree_product_properties: {value:arrMaterials}, spree_properties:{name:[property_material_name, property_color_name]}).page(page)
      #products = Spree::Product.includes(:product_properties, :properties).where(spree_product_properties: {value:values.uniq}, spree_properties:{name:[property_material_name, property_color_name]}).page(page)#.group(:name)

      #products = Spree::Product.find_by_sql('select p.name, pp.value as pp_value, product.name, product.id as product_id  from  spree_products as product, spree_product_properties as pp, spree_properties as p
      #   where product.id = pp.product_id and pp.property_id = p.id and p.name in ("Color","Material") and pp.value in ("Canvas","Yellow") group by p.name
      #    ;');
    end

    # if only ShopByColor, ShopByMaterial and ShopByPrice filters are applied together.
    if arrColors.present? && arrMaterials.present? && arrPrices.present? && arrCategories.blank?
      values = arrColors + arrMaterials
      products = Spree::Product.
          includes(:product_properties, :properties).
          where("spree_product_properties.value" => values, "spree_properties.name" => [property_color_name, property_material_name]
          ).uniq
      products = filter_products_by_price(products, arrPrices).page(page) if products.present?
      #TODO: add variants from option_values to products if needed
    end

    # if all filters (ShopByColor, ShopByMaterial, ShopByPrice, ShopByCategory, ShopByBrand) are applied together.
    if arrColors.present? && arrMaterials.present? && arrPrices.present? && arrCategories.present?
      values = arrColors + arrMaterials
      taxons = Spree::Taxon.where(name: arrCategories)
      products = Spree::Product.in_taxons(taxons).includes(:product_properties, :properties).
          where("spree_product_properties.value" => values, "spree_properties.name" => [property_color_name, property_material_name]
          ).uniq
      products = filter_products_by_price(products, arrPrices).page(page) if products.present?
      #TODO: add variants from option_values to products if needed
    end

    # if ShopByMaterial and ShopByPrice filters applied
    if arrMaterials.present? && arrPrices.present? && arrCategories.blank? && arrColors.blank?
      priceMin, priceMax = get_min_and_max_price_from_string_array(arrPrices)

      productItems = Spree::Product.
          includes(:product_properties, :properties)
                             .where("spree_product_properties.value" => arrMaterials, "spree_properties.name" => property_material_name)
                             .uniq.price_between(priceMin, priceMax).page(page)

      #TODO: add variants from option_values to products if needed
      # # searching in product variants
      # variants = Spree::Variant.includes(:option_values).where("spree_option_values.presentation" => arrMaterials)
      #                .uniq.joins(:prices).where("spree_prices.amount > ? and spree_prices.amount < ?", priceMin, priceMax).page(page) #search products by material in his variants.
      # variants.each { |variant| productMaterials << variant if variant.present? && variant.product.present? } # add variant to products

      products = productItems
    end

    # if ShopByMaterial, ShopByPrice, ShopByCateory and ShopByBrand filters applied
    if arrMaterials.present? && arrPrices.present? && arrCategories.present? && arrColors.blank?
      taxons = Spree::Taxon.where(name: arrCategories)
      priceMin, priceMax = get_min_and_max_price_from_string_array(arrPrices)

      productItems = Spree::Product.in_taxons(taxons).includes(:product_properties, :properties).
          where("spree_product_properties.value" => values, "spree_properties.name" => [property_color_name, property_material_name])
            .includes(:product_properties, :properties)
              .where("spree_product_properties.value" => arrMaterials, "spree_properties.name" => property_material_name)
                 .uniq.price_between(priceMin, priceMax).page(page)

      #TODO: check it (may be return duplicates of variants but not sure)
      # #TODO: add variants from option_values to products if needed
      # productsForVariants = Spree::Product.in_taxons(taxons).uniq.price_between(priceMin, priceMax).page(page)
      # productsForVariants.each do |product|
      #   variants = product.variants.includes(:option_values).where("spree_option_values.presentation" => arrMaterials).uniq.page(page) if product.present? && product.variants.present?
      #   variants.each { |variant| productMaterials << variant if variant.present? } if variants.present? # add variant to products
      # end
      products = productItems
    end

    # If filters (ShopByPrice, ShopByCategory, ShopByBrand) applied together.
    if arrPrices.present? && arrCategories.present? && arrColors.blank? && arrMaterials.blank?
      taxons = Spree::Taxon.where(name: arrCategories)
      products = Spree::Product.in_taxons(taxons).uniq
      products = filter_products_by_price(products, arrPrices).page(page) if products.present?
    end

    # if filters (ShopByColor, ShopByCategory, ShopByBrand) are applied together.
    if arrColors.present? && arrCategories.present? && arrMaterials.blank? && arrPrices.blank?
      taxons = Spree::Taxon.where(name: arrCategories)
      productColors = Spree::Product.in_taxons(taxons).includes(:product_properties, :properties)
          .where("spree_product_properties.value" => arrColors, "spree_properties.name" => property_color_name)
              .uniq.page(page)

      #TODO: check it (may be return duplicates of variants but not sure)
      #TODO: add variants from option_values to products if needed
      # productsForVariants = Spree::Product.in_taxons(taxons)
      # productsForVariants.each do |product|
      #   variants = product.variants.includes(:option_values).where("spree_option_values.presentation" => arrColors).uniq.page(page) if product.present? && product.variants.present?
      #   variants.each { |variant| productColors << variant if variant.present? } if variants.present? # add variant to products
      # end
      products = productColors #.uniq
    end

    # if only filters (ShopByColor and ShopByPrice) applied
    if arrColors.present? && arrPrices.present? && arrCategories.blank? && arrMaterials.blank?
      priceMin, priceMax = get_min_and_max_price_from_string_array(arrPrices)
      productColors = Spree::Product.includes(:product_properties, :properties)
          .where("spree_product_properties.value" => arrColors, "spree_properties.name" => property_color_name)
          .uniq.price_between(priceMin, priceMax).page(page)

      #TODO: add variants from option_values to products if needed
      # # searching in product variants
      # variants = Spree::Variant.includes(:option_values).where("spree_option_values.presentation" => arrColors).
      #     joins(:prices).where("spree_prices.amount > ? and spree_prices.amount < ?", priceMin, priceMax).page(page) #search products by color in his variants.
      # variants.each { |variant| productColors << variant if variant.present? && variant.product.present? } # add variant to products

      products = productColors
    end

    # if only filters (ShopByMaterial, ShopByBrand, ShopByCategory) applied
    if arrMaterials.present? && arrCategories.present? && arrPrices.blank? && arrColors.blank?
      taxons = Spree::Taxon.where(name: arrCategories)
      productItems = Spree::Product.in_taxons(taxons).includes(:product_properties, :properties)
        .where("spree_product_properties.value" => arrMaterials, "spree_properties.name" => property_material_name)
          .uniq.page(page)

      #TODO: add variants from option_values to products if needed
      products = productItems
    end

    # if only filters (ShopByColor, ShopByMaterial, ShopByBrand, ShopByCategory) applied
    if arrMaterials.present? && arrColors.present? && arrCategories.present? && arrPrices.blank?
      values = arrMaterials + arrColors
      taxons = Spree::Taxon.where(name: arrCategories)
      productItems = Spree::Product.in_taxons(taxons).includes(:product_properties, :properties)
        .where("spree_product_properties.value" => values.uniq, "spree_properties.name" => [property_color_name, property_material_name])
          .uniq.page(page)
      #TODO: add variants from option_values to products if needed
      products = productItems
    end

    # if only filters (ShopByMaterial, ShopByBrand, ShopByCategory) applied
    if arrMaterials.present? && arrCategories.present? && arrPrices.blank? && arrColors.blank?
      taxons = Spree::Taxon.where(name: arrCategories)
      productItems = Spree::Product.in_taxons(taxons).includes(:product_properties, :properties)
        .where("spree_product_properties.value" => arrMaterials, "spree_properties.name" => property_material_name)
        .uniq.page(page)
      #TODO: add variants from option_values to products if needed
      products = productItems
    end

    # if only filters (ShopByColors, ShopByPrice, ShopByBrand, ShopByCategory) applied
    if arrColors.present? && arrCategories.present? && arrPrices.present? && arrMaterials.blank?
      priceMin, priceMax = get_min_and_max_price_from_string_array(arrPrices)
      taxons = Spree::Taxon.where(name: arrCategories)
      productItems = Spree::Product.in_taxons(taxons).includes(:product_properties, :properties)
         .where("spree_product_properties.value" => arrColors, "spree_properties.name" => property_color_name)
         .uniq.price_between(priceMin, priceMax).page(page)
      #TODO: add variants from option_values to products if needed
      products = productItems
    end

    # if no any selected filters - display all products
    if arrCategories.blank? && arrColors.blank? && arrMaterials.blank? && arrPrices.blank?
      products = Spree::Product.page(page)
    end

    respond_to_and_exit(products)
  end


  private

  def filter_products_by_price(items, arrPrices)
    priceMin, priceMax = get_min_and_max_price_from_string_array(arrPrices)
    products = items.price_between(priceMin, priceMax)
  end

  def respond_to_and_exit(items)
    @products = items #.uniq
    respond_to do |format|
      format.js # { render errors: @errors, :products => @products }
    end
  end

  def split_params ajax_params
    arrSplit = []
    if ajax_params.present?
      arrSplit = ajax_params.split(',')
    end
    return arrSplit
  end

  def get_min_and_max_price_from_string_array(productPrices)
    intPrices = []
    productPrices.each do |productPrice|
      splitItems = productPrice.split(",")
      splitItems.each do |item|
        intPrices << item.to_i
      end
    end

    priceMin = intPrices.min
    priceMax = intPrices.max

    return priceMin, priceMax
  end

  META = [:id, :created_at, :updated_at, :interacted_at, :confirmed_at]

  def eql_attributes?(original, new)
    original = original.attributes.with_indifferent_access.except(*META)
    new = new.attributes.symbolize_keys.with_indifferent_access.except(*META)
    original == new
  end

  def add_or_eq(oldItems, newItems)
    results = []
    if oldItems.present? && newItems.present?
      newItems.each do |newItem|
        oldItems.each do |oldItem|
          results << newItem if eql_attributes?(newItem, oldItem) #eql_attributes? newItem, oldItem
        end
      end
    elsif oldItems.present? && newItems.blank?
      results = oldItems
    elsif newItems.present? && oldItems.blank?
      results = newItems
    else
      results = oldItems
    end

    return results
  end

  def get_available_colors_from_variants
    colors = []
    Spree::Variant.all.each do |variant|
      variant.product.properties.each do |property|
        colors << property.name if property.name == property_color_name #or property.presentation==property_color_name
      end
    end
    return colors.uniq!
  end

  def products_liked
    @products = Spree::Product.all.limit(3) #.first(3)
    #@products = Spree::Product.paginate(:page => params[:page], :per_page => 30) #will_paginate
    #@products_will = Spree::Product.page(params[:page]).per(25) #kaminari
    if request.xhr?
      render :partial => "spree/shared/products_liked"
    end
  end

  def product_selected
    @products = Spree::Product.take(3)
    @product_item = Spree::Product.find(1)
  end

  def format_price(amount)
    Spree::Money.new(amount)
  end

end