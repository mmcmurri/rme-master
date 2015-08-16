Spree::HomeController.class_eval do
  before_action :material, :only => [:product_selected, :products_liked]
  protect_from_forgery except: :shops_ajax #fixed Security warning: an embedded <script> tag on another site requested protected JavaScript. If you know what you're doing, go ahead and disable forgery protection on this action to permit cross-origin JavaScript embedding.

  def index
    @searcher = build_searcher(params.merge(include_images: true))
    @products = @searcher.retrieve_products
    @taxonomies = Spree::Taxonomy.includes(root: :children)

    #@material = Spree::Property.find_by(name:"Material")
    #@color = Spree::Property.find_by(name:"Color")

    #@material = Spree::OptionType.find_by_presentation("Material")
    #@color = Spree::OptionType.find_by_presentation("Color")

    #@colors = get_available_colors_from_variants()
    @colors = Spree::OptionType.find_by(presentation:"Color").option_values
    @materials = Spree::OptionType.find_by(presentation:"Material").option_values

    @prices = get_prices();

    #if request.xhr? # get ajax request or in shops_ajax() method
    #  @product_list = [];
    #  if params["colors"].present?
    #    @colors.each do |color|
    #      color.variants.each do |variant|
    #        @product_list << variant.product if variant.present? && variant.product.present?
    #      end
    #    end
    #  end
    #  render :json => {
    #      ajax:"ajax", :products => @product_list, searcher:@searcher, taxonomies:@taxonomies, colors:@colors, materials:@materials, prices:@prices
    #  }
    #end
  end

  def shops_ajax
    product_list = []
    @errors = []

    if params[:colors].present?
      splitItems = params[:colors].split(",") # here we create the color array/hash for searching products by them.

      #search products by color in his properties
      product_list = Spree::Product.includes(:product_properties, :properties).where("spree_product_properties.value" => splitItems, "spree_properties.name"=>"Color")

      variants = Spree::Variant.includes(:option_values).where("spree_option_values.presentation" => splitItems) #search products by color in his variants.
      variants.each { |variant| product_list << variant if variant.present? && variant.product.present? }        #add variants to products

      @errors << "no products with selected color(s) in request" if product_list.blank?

      # @colors = Spree::OptionType.find_by(presentation:"Color").try(:option_values)
      # @colors.where(name: splitItems).each do |color|
      #   color.variants.each do |variant|
      #     product_list << variant.product if variant.present? && variant.product.present?
      #   end
      # end
    else
      #TODO: display the filters at the top of the products section.
    end

    productMaterials = []
    if params[:materials].present?
      @materials = Spree::OptionType.find_by(presentation:"Material").try(:option_values)
      splitItems = params[:materials].split(",")
      @materials.where(name: splitItems).each do |color|
        color.variants.each do |variant|
          productMaterials << variant.product if variant.present? && variant.product.present?
        end
      end
      @errors << "no products with selected material(s) in request" if productMaterials.blank?
    else
      #TODO: display the filters at the top of the products section.
    end
    product_list = add_or_eq(product_list, productMaterials)


    productCategories = []
    if params[:categories].present?
      splitItems = params[:categories].split(",")
      Spree::Taxon.where(name: splitItems).each do |taxon|
        taxon.products.each do |product|
          productCategories << product if product.present?
        end
      end
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

      productPrices = Spree::Product.price_between(priceMin, priceMax)
      product_list = add_or_eq(product_list, productPrices)
      @errors << "no products with selected price(s) in request" if productPrices.blank?

    else
      #TODO: display the filters at the top of the products section.
    end

    if product_list.present?
      @products = product_list.uniq
    elsif (params[:categories].blank? && params[:colors].blank? && params[:prices].blank? && params[:materials].blank?)
      @products = Spree::Product.all
    end

    respond_to do |format|
      format.js { render ajax:"ajaxOk", errors:@errors, :products => @products }
    end

    #render :json => {
    #    ajax:"ajax", :products => @product_list, searcher:@searcher, taxonomies:@taxonomies, colors:@colors, materials:@materials, prices:@prices
    #}
  end
  private

  def add_or_eq(oldItems, newItems)
    results = []
    if oldItems.present?
      results = oldItems+newItems
    else
      results = newItems
    end
    return results
  end

  def get_prices()
    return [
        {name:"$", min:"0", max:"10"},
        {name:"$$", min:"11", max:"100"},
        {name:"$$$", min:"101", max:"1000"},
        {name:"$$$$", min:"1001", max:"10000"},
        {name:"$$$$$", min:"10001", max:"100000"}
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
    @products = Spree::Product.all.limit(3)#.first(3)
    #@products = Spree::Product.paginate(:page => params[:page], :per_page => 30) #will_paginate
    #@products_will = Spree::Product.page(params[:page]).per(25) #kaminari
    if request.xhr?
      render :partial=>"spree/shared/products_liked"
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