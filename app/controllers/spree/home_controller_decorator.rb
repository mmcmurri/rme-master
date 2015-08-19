Spree::HomeController.class_eval do
  before_action :material, :only => [:product_selected, :products_liked]
  protect_from_forgery except: :shops_ajax #fixed Security warning: an embedded <script> tag on another site requested protected JavaScript. If you know what you're doing, go ahead and disable forgery protection on this action to permit cross-origin JavaScript embedding.

  def index
    @searcher = build_searcher(params.merge(include_images: true))
    @products = @searcher.retrieve_products
    @taxonomies = Spree::Taxonomy.includes(root: :children)

    # @material = Spree::Property.find_by(name:"Material")
    # @color = Spree::Property.find_by(name:"Color")

    #@material = Spree::OptionType.find_by_presentation("Material")
    #@color = Spree::OptionType.find_by_presentation("Color")

    #@colors = get_available_colors_from_variants()

    colorPropertyName = "Color"
    materialPropertyName = "Material"

    propertyColor = Spree::Property.find_by(name: colorPropertyName)
    propertyMaterial = Spree::Property.find_by(name: materialPropertyName)

    materialsFromProperties = Spree::ProductProperty.where(property_id: propertyMaterial)
    colorsFromProperties = Spree::ProductProperty.where(property_id: propertyColor)

    colorOptionType = Spree::OptionType.find_by(presentation: colorPropertyName) if Spree::OptionType.exists?(presentation: colorPropertyName)
    materialOptionType = Spree::OptionType.find_by(presentation: materialPropertyName) if Spree::OptionType.exists?(presentation: materialPropertyName)

    colorsFromOptionValues = colorOptionType.option_values if colorOptionType.present? && colorOptionType.option_values.present?
    materialsFromOptionValues = materialOptionType.option_values if materialOptionType.present? && materialOptionType.option_values.present?


    @colors = []
    colorsFromOptionValues.each { |p| @colors << p.presentation } if colorsFromOptionValues.present?
    colorsFromProperties.each { |p| @colors << p.value } if materialsFromOptionValues

    @materials = []
    materialsFromOptionValues.each { |p| @materials << p.presentation } if materialsFromOptionValues.present?
    materialsFromProperties.each { |p| @materials << p.value } if materialsFromProperties.present?

    @materials.uniq!
    @colors.uniq!

    @prices = get_prices();

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

    sku = params[:sku]
    arrColors = split_params params[:colors]
    arrMaterials = split_params params[:materials]
    arrCategories = split_params split_params params[:categories]
    arrPrices = params[:prices] if params[:prices].present?

    products = []

    #searching by sku (product code)
    if sku.present?
      variants = Spree::Variant.where(sku: sku.strip.upcase)
      respond_to_and_exit(variants)
      return
    end

    # Search/filtering the products by their brands or/and their categories only.
    if arrCategories.present? && arrColors.blank? && arrMaterials.blank? && arrPrices.blank?
      taxons = Spree::Taxon.where(name: arrCategories)
      products = Spree::Product.in_taxons(taxons)
    end

    # if only filter.shop_by_price applied
    if arrPrices.present? && arrCategories.blank? && arrColors.blank? && arrMaterials.blank?
      products = filter_products_by_price(Spree::Product.all, arrPrices)
    end

    # if only filter.shop_by_material applied
    if arrMaterials.present? && arrPrices.blank? && arrCategories.blank? && arrColors.blank?
      productMaterials = Spree::Product.includes(:product_properties, :properties).where("spree_product_properties.value" => arrMaterials, "spree_properties.name" => "Material").uniq

      # searching in product variants
      variants = Spree::Variant.includes(:option_values).where("spree_option_values.presentation" => arrMaterials) #search products by material in his variants.
      variants.each { |variant| productMaterials << variant if variant.present? && variant.product.present? } # add variant to products

      products = productMaterials
    end

    # if only filter.shop_by_color applied
    if arrColors.present? && arrPrices.blank? && arrCategories.blank? && arrMaterials.blank?
      productColors = Spree::Product.includes(:product_properties, :properties).where("spree_product_properties.value" => arrColors, "spree_properties.name" => "Color").uniq

      # searching in product variants
      variants = Spree::Variant.includes(:option_values).where("spree_option_values.presentation" => arrColors) #search products by color in his variants.
      variants.each { |variant| productColors << variant if variant.present? && variant.product.present? } # add variant to products

      products = productColors
    end

    # if only ShopByColor and ShopByMaterial filters are applied together.
    if arrColors.present? && arrMaterials.present? && arrPrices.blank? && arrCategories.blank?
      values = arrColors + arrMaterials
      products = Spree::Product.
          includes(:product_properties, :properties).
          where("spree_product_properties.value" => values, "spree_properties.name" => ["Color", "Material"]
          ).uniq
    end

    # if only ShopByColor, ShopByMaterial and ShopByPrice filters are applied together.
    if arrColors.present? && arrMaterials.present? && arrPrices.present? && arrCategories.blank?

      values = arrColors + arrMaterials
      products = Spree::Product.
          includes(:product_properties, :properties).
          where("spree_product_properties.value" => values, "spree_properties.name" => ["Color", "Material"]
          ).uniq
      products = filter_products_by_price(products, arrPrices) if products.present?
    end

    # if all filters (ShopByColor, ShopByMaterial, ShopByPrice, ShopByCategories) are applied together.
    if arrColors.present? && arrMaterials.present? && arrPrices.present? && arrCategories.blank?
      values = arrColors + arrMaterials
      products = Spree::Product.
          includes(:product_properties, :properties).
          where("spree_product_properties.value" => values, "spree_properties.name" => ["Color", "Material"]
          ).uniq
      products = filter_products_by_price(products, arrPrices) if products.present?
      #TODO: add variants from option_values to products if needed
    end

    # if all filters (ShopByColor, ShopByMaterial, ShopByPrice, ShopByCategory, ShopByBrand) are applied together.
    if arrColors.present? && arrMaterials.present? && arrPrices.present? && arrCategories.present?
      values = arrColors + arrMaterials
      taxons = Spree::Taxon.where(name: arrCategories)
      products = Spree::Product.in_taxons(taxons).includes(:product_properties, :properties).
          where("spree_product_properties.value" => values, "spree_properties.name" => ["Color", "Material"]
          ).uniq
      products = filter_products_by_price(products, arrPrices) if products.present?
      #TODO: add variants from option_values to products if needed
    end

    # if ShopByMaterial and ShopByPrice filters applied
    if arrMaterials.present? && arrPrices.present? && arrCategories.blank? && arrColors.blank?
      priceMin, priceMax = get_min_and_max_price_from_string_array(arrPrices)

      productMaterials = Spree::Product.
          includes(:product_properties, :properties)
                             .where("spree_product_properties.value" => arrMaterials, "spree_properties.name" => "Material")
                             .uniq.price_between(priceMin, priceMax)

      # searching in product variants
      variants = Spree::Variant.includes(:option_values).where("spree_option_values.presentation" => arrMaterials)
                     .uniq.joins(:prices).where("spree_prices.amount > ? and spree_prices.amount < ?", priceMin, priceMax) #search products by material in his variants.
      variants.each { |variant| productMaterials << variant if variant.present? && variant.product.present? } # add variant to products

      products = productMaterials
    end

    # if ShopByMaterial, ShopByPrice, ShopByCateory and ShopByBrand filters applied
    if arrMaterials.present? && arrPrices.present? && arrCategories.present? && arrColors.blank?
      taxons = Spree::Taxon.where(name: arrCategories)
      priceMin, priceMax = get_min_and_max_price_from_string_array(arrPrices)

      productMaterials = Spree::Product.in_taxons(taxons).includes(:product_properties, :properties).
          where("spree_product_properties.value" => values, "spree_properties.name" => ["Color", "Material"]
          ).
          includes(:product_properties, :properties)
                             .where("spree_product_properties.value" => arrMaterials, "spree_properties.name" => "Material")
                             .uniq.price_between(priceMin, priceMax)

      #TODO: check it (may be return duplicates of variants)
      productsForVariants = Spree::Product.in_taxons(taxons).uniq.price_between(priceMin, priceMax)
      productsForVariants.each do |product|
        variants = product.variants.includes(:option_values).where("spree_option_values.presentation" => arrMaterials).uniq if product.present? && product.variants.present?
        variants.each { |variant| productMaterials << variant if variant.present? } if variants.present? # add variant to products
      end
      products = productMaterials #.uniq
    end

    # If filters (ShopByPrice, ShopByCategory, ShopByBrand) applied together.
    if arrPrices.present? && arrCategories.present? && arrColors.blank? && arrMaterials.blank?
      taxons = Spree::Taxon.where(name: arrCategories)
      products = Spree::Product.in_taxons(taxons).uniq
      products = filter_products_by_price(products, arrPrices) if products.present?
    end

    # if filters (ShopByColor, ShopByCategory, ShopByBrand) are applied together.
    if arrColors.present? && arrCategories.present? && arrMaterials.blank? && arrPrices.blank?
      taxons = Spree::Taxon.where(name: arrCategories)
      productColors = Spree::Product.in_taxons(taxons).includes(:product_properties, :properties).
          where("spree_product_properties.value" => arrColors, "spree_properties.name" => "Color"
          ) #.uniq
      #TODO: add variants from option_values to products if needed
      #TODO: check it (may be return duplicates of variants)
      productsForVariants = Spree::Product.in_taxons(taxons)
      productsForVariants.each do |product|
        variants = product.variants.includes(:option_values).where("spree_option_values.presentation" => arrColors).uniq if product.present? && product.variants.present?
        variants.each { |variant| productColors << variant if variant.present? } if variants.present? # add variant to products
      end
      products = productColors #.uniq
    end

    # if only filters (ShopByColor and ShopByPrice) applied
    if arrColors.present? && arrPrices.present? && arrCategories.blank? && arrMaterials.blank?
      priceMin, priceMax = get_min_and_max_price_from_string_array(arrPrices)

      productColors = Spree::Product.includes(:product_properties, :properties).
          where("spree_product_properties.value" => arrColors, "spree_properties.name" => "Color").
          uniq.price_between(priceMin, priceMax)

      # searching in product variants
      variants = Spree::Variant.includes(:option_values).where("spree_option_values.presentation" => arrColors).
          joins(:prices).where("spree_prices.amount > ? and spree_prices.amount < ?", priceMin, priceMax) #search products by color in his variants.
      variants.each { |variant| productColors << variant if variant.present? && variant.product.present? } # add variant to products

      products = productColors
    end

    # if only filters (ShopByMaterial, ShopByBrand, ShopByCategory) applied
    if arrMaterials.present? && arrCategories.present? && arrPrices.blank? && arrColors.blank?
      taxons = Spree::Taxon.where(name: arrCategories)
      productMaterials = Spree::Product.includes(:product_properties, :properties).
          where("spree_product_properties.value" => arrMaterials, "spree_properties.name" => "Material")

      #TODO: add variants from option_values to products if needed
      products = productMaterials
    end


    # if no any selected filters - display all products
    if arrCategories.blank? && arrColors.blank? && arrMaterials.blank? && arrPrices.blank?
      products = Spree::Product.all
    end

    respond_to_and_exit(products)

    # products.each do |product|
    #   if product.variants.present?
    #     product.variants.each do |variant|
    #       if variant.option_values
    #         arrayTemp = []
    #         arrayTemp += arrColors if arrColors.present?
    #         arrayTemp += arrMaterials if arrMaterials.present?
    #         variant.option_values.where(presentation: arrayTemp).each do |v|
    #           @shops << v if v.present?
    #         end
    #         # variant.option_values.each do |ov|
    #         #   if ov.name == ""
    #         #       @shops << variant if variant.present?
    #         #   end
    #         # end
    #       end
    #     end
    #     #@shops << product
    #   end
    # end
  end

  def shop_ajax_add_mode
    product_list = []
    @errors = []
    @products = []
    # splitItems = params[:colors].split(',')
    # # splitItems<<"White"
    # # @products = Spree::Product.includes(:product_properties, :properties).where("spree_product_properties.value" => splitItems, "spree_properties.name"=>"Color")
    # @products = Spree::Product.includes(:product_properties, :properties)
    #                 .where("spree_product_properties.value" => splitItems, "spree_properties.name" => "Color")
    # respond_to do |format|
    #   format.js { render ajax: "ajaxOk", errors: @errors, :products => @products }
    # end
    # return
    propertyParams = []

    if params[:colors].present?
      splitItems = params[:colors].split(",") # here we create the color array/hash for searching products by them.
      # splitItems = ["Red"]
      #search products by color in his properties
      product_list = Spree::Product.includes(:product_properties, :properties).where("spree_product_properties.value" => splitItems, "spree_properties.name" => "Color").uniq

      variants = Spree::Variant.includes(:option_values).where("spree_option_values.presentation" => splitItems).uniq #search products by color in his variants.
      variants.each { |variant| product_list << variant if variant.present? && variant.product.present? } #add variants to products
      # product_list
      @errors << "no products with selected color(s) in request" if product_list.blank?

      # @colors = Spree::OptionType.find_by(name:"Color").try(:option_values)
      # @colors.where(name: splitItems).each do |color|
      #   color.variants.each do |variant|
      #     product_list << variant if variant.present? && variant.product.present?
      #   end
      # end
    else
      #TODO: display the filters at the top of the products section.
    end

    # @products = product_list
    # respond_to do |format|
    #   format.js { render ajax: "ajaxOk", errors: @errors, :products => @products }
    # end
    # return;

    productMaterials = []
    if params[:materials].present?
      splitItems = params[:materials].split(",")
      productMaterials = Spree::Product.includes(:product_properties, :properties).where("spree_product_properties.value" => splitItems, "spree_properties.name" => "Material").uniq

      variants = Spree::Variant.includes(:option_values).where("spree_option_values.presentation" => splitItems) #search products by material in his variants.
      variants.each { |variant| productMaterials << variant if variant.present? && variant.product.present? } #add variants to products

      # @materials = Spree::OptionType.find_by(name:"Material").try(:option_values)
      # splitItems = params[:materials].split(",")
      # @materials.where(name: splitItems).each do |material|
      #   material.variants.each do |variant|
      #     productMaterials << variant if variant.present? && variant.product.present?
      #   end
      # end

      @errors << "no products with selected material(s) in request" if productMaterials.blank?
    else
      #TODO: display the filters at the top of the products section.
    end
    product_list = add_or_eq(product_list, productMaterials)


    productCategories = []
    if params[:categories].present?

      # splitItems = params[:categories].split(",")
      # #productCategories = Spree::Product.includes(:product_properties, :properties).where("spree_product_properties.value" => splitItems, "spree_properties.name" => "Brand")
      # productCategories = Spree::Product.includes(:taxons).where("spree_taxons.name" => splitItems)
      # if productCategories.blank? #search in taxonomies ("Clothing" for example)
      #   productCategories = Spree::Taxonomy.where(:name => splitItems)
      # end

      splitItems = params[:categories].split(",") # ["Bags","Mugs", "Clothing"]
      #productCategories = Spree::Product.includes(:taxons).where("spree_taxons.name":splitItems)

      taxons = Spree::Taxon.where(name: splitItems)
      productCategories = Spree::Product.in_taxons(taxons)

      # splitItems = ["Mugs", "Bags"]
      # splitItems = ["Clothing"]
      # t=Spree::Taxon.where(name:splitItems)
      # Spree::Product.in_taxons(t).count

      # Spree::Taxon.find_by(name: splitItems).each do |taxon|
      #   taxon.products.each do |product|
      #     productCategories << product if product.present?
      #   end
      # end

      @errors << "no any products with selected categor(y/ies) or brand(s) in request." if productCategories.blank?
    else
      #TODO: display the filters at the top of the products section.
    end
    product_list = add_or_eq(product_list, productCategories)

    if params[:prices].present?

      productPrices = params[:prices]
      intPrices = []
      productPrices.each do |productPrice|
        splitItems = productPrice.split(",")
        splitItems.each do |item|
          intPrices << item.to_i
        end
      end

      priceMin = intPrices.min
      priceMax = intPrices.max

      if product_list.present?
        product_list.price_between(priceMin, priceMax)
      else
        productPrices = Spree::Product.price_between(priceMin, priceMax)
      end
      # product_list = add_or_eq(product_list, productPrices)
      @errors << "no products with selected price(s) in request" if productPrices.blank?

    else
      #TODO: display the filters at the top of the products section.
    end

    if product_list.present?
      # product_list = product_list.uniq
      @products = product_list
    elsif (params[:categories].blank? && params[:colors].blank? && params[:prices].blank? && params[:materials].blank?)
      @products = Spree::Product.all
    end

    respond_to do |format|
      format.js { render ajax: "ajaxOk", errors: @errors, :products => @products }
    end

    #render :json => {
    #    ajax:"ajax", :products => @product_list, searcher:@searcher, taxonomies:@taxonomies, colors:@colors, materials:@materials, prices:@prices
    #}
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

  def get_prices()
    return [
        {name: "$", min: "0", max: "10"},
        {name: "$$", min: "11", max: "100"},
        {name: "$$$", min: "101", max: "1000"},
        {name: "$$$$", min: "1001", max: "10000"},
        {name: "$$$$$", min: "10001", max: "100000"}
    ]
  end

  def get_available_colors_from_variants
    colors = []
    Spree::Variant.all.each do |variant|
      variant.product.properties.each do |property|
        colors << property.name if property.name == "Color" #or property.presentation=="Color"
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