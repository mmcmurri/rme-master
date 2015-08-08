Spree::ProductsController.class_eval do
  before_filter :load_data, :only => [:product_selected, :products_liked]

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
