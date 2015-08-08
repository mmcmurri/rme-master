Spree::HomeController.class_eval do
  before_action :material, :only => [:product_selected, :products_liked]

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

  end

  private

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

end