Spree::HomeController.class_eval do
  before_action :material, :only => [:product_selected, :products_liked]
  protect_from_forgery except: :shops_ajax #fixed Security warning: an embedded <script> tag on another site requested protected JavaScript. If you know what you're doing, go ahead and disable forgery protection on this action to permit cross-origin JavaScript embedding.

  def index
    @taxonomies = Spree::Taxonomy.all #includes(root: :children)
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

    sku = params[:sku]
    arrCategories = split_params params[:categories]
    products = []
    arrPrices = []

    #searching by sku (product code)
    if sku.present?
      variants = Spree::Variant.where(sku: sku.strip.upcase) #.page(page)
      respond_to_and_exit(variants)
      return
    end

    if arrCategories.present?
      taxons = Spree::Taxon.where(id: arrCategories)

      # shop by price level
      # taxons_with_prices = Spree::Taxon.where("name like ?", "$%")
      taxons_with_prices = taxons.where("name like ?", "$%")
      if taxons_with_prices.present?
        taxons_with_prices.each do |taxon|
          min_max = taxon.description.split(",") if taxon.description.present?
          arrPrices << min_max.try(:first)
          arrPrices << min_max.try(:second)
        end
      end

      priceMin, priceMax = get_min_and_max_price_from_string_array(arrPrices)
      if priceMin.present? && priceMax.present?
        products = Spree::Product.in_taxons(taxons).price_between(priceMin, priceMax).page(page)
      else
        products = Spree::Product.in_taxons(taxons).page(page)
      end
    elsif arrCategories.blank?
      products = Spree::Product.page(page) # display all products by default
    end

    respond_to_and_exit(products)
  end


  private

  def filter_products_by_price(items, arrPrices)
    priceMin, priceMax = get_min_and_max_price_from_string_array(arrPrices)
    products = items.price_between(priceMin, priceMax)
  end

  def respond_to_and_exit(items)
    @products = items
    respond_to do |format|
      format.js # { render errors: @errors, :products => @products }
    end
  end

  def split_params ajax_params
    arrSplit = []
    arrSplit = ajax_params.split(',') if ajax_params.present?
    return arrSplit
  end

  def get_min_and_max_price_from_string_array(productPrices)
    intPrices = []
    productPrices.each do |productPrice|
      splitItems = productPrice.try(:split, ",")
      if splitItems.present? && splitItems.any?
        splitItems.each do |item|
          intPrices << item.to_i
        end
      end
    end

    priceMin = intPrices.min
    priceMax = intPrices.max

    return priceMin, priceMax
  end

end