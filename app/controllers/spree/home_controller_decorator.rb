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
    logger.info request.env
    #@products = Spree::Product.limit(2)
    @colors = Spree::OptionType.find_by(presentation:"Color").try(:option_values)
    @materials = Spree::OptionType.find_by(presentation:"Material").try(:option_values)

    product_list = [];
    @error = "";


    if params[:colors].present?
      @error += "no colors in request\n"
      splitItems = params[:colors].split(",")
      @colors.where(name: splitItems).each do |color|
        color.variants.each do |variant|
          product_list << variant.product if variant.present? && variant.product.present?
        end
      end
    end


    productMaterials = []
    if params[:materials].present?
      @error += "no materials in request\n"
      splitItems = params[:materials].split(",")
      @materials.where(name: splitItems).each do |color|
        color.variants.each do |variant|
          productMaterials << variant.product if variant.present? && variant.product.present?
        end
      end
    end
    product_list = add_or_eq(product_list, productMaterials)


    productCategories = []
    if params[:categories].present?
      @error += "no categories in request\n"
      splitItems = params[:categories].split(",")
      Spree::Taxon.where(name: splitItems).each do |taxon|
        taxon.products.each do |product|
          productCategories << product if product.present?
        end
      end
    end
    product_list = add_or_eq(product_list, productCategories)

    if params[:prices].present?
      @error += "no prices in request\n"

      # Spree::Product.add_search_scope :price_range_any do |*opts|
      #   conds = opts.map {|o| price_filter[:conds][o]}.reject { |c| c.nil? }
      #   scope = conds.shift
      #   conds.each do |new_scope|
      #     scope = scope.or(new_scope)
      #   end
      #   Spree::Product.joins(master: :default_price).where(scope)
      # end

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

    end

    if product_list.present?
      @products = product_list.uniq
    elsif (params[:categories].blank? && params[:colors].blank? && params[:prices].blank? && params[:materials].blank?)
      @products = Spree::Product.all
    end

    respond_to do |format|
      format.js { render ajax:"ajaxOk", error:@error, :products => @products }
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
      # oldItems.each do |oldItem|
      #   newItems.each do |newItem|
      #     # results << newItem if newItem.name.equal?(oldItem.name)# && newItem.id==oldItem.id
      #   end
      # end
      #oldItems = oldItems.find(newItems) if newItems.present?
      #oldItems = [] if oldItems.blank? && oldItems.count<1
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

  def price_filter
    v = Spree::Price.arel_table
    conds = [ [ Spree.t(:under_price, price: format_price(10))     , v[:amount].lteq(10)],
              [ "#{format_price(10)} - #{format_price(15)}"        , v[:amount].in(10..15)],
              [ "#{format_price(15)} - #{format_price(18)}"        , v[:amount].in(15..18)],
              [ "#{format_price(18)} - #{format_price(20)}"        , v[:amount].in(18..20)],
              [ Spree.t(:or_over_price, price: format_price(20)) , v[:amount].gteq(20)]]
    {
        name:   Spree.t(:price_range),
        scope:  :price_range_any,
        conds:  Hash[*conds.flatten],
        labels: conds.map { |k,v| [k, k] }
    }
  end

  def format_price(amount)
    Spree::Money.new(amount)
  end

end