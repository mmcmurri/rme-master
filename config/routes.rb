Rails.application.routes.draw do

  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  root :to => 'home#index'

  get '/index', to: 'home#index', as: 'index'
  get '/our_service', to: 'home#our_service', as: 'our_service'
  get '/custom', to: 'home#custom', as: 'custom'
  get '/business', to: 'home#business', as: 'business'
  get '/login_portal', to: 'home#login_portal', as: 'login_portal'
  get '/customer_information', to: 'home#customer_information', as: 'customer_information'
  get '/register', to: 'home#register', as: 'register'
  get '/contact_us', to: 'home#contact_us', as: 'contact_us'
  get '/forms_submissions_home', to: 'home#forms_submissions_home', as: 'forms_submissions_home'
  get '/file_complaint', to: 'home#file_complaint', as: 'file_complaint'
  get '/availablity_calendar', to: 'home#availablity_calendar', as: 'availablity_calendar'
  get '/site_damage', to: 'home#site_damage', as: 'site_damage'
  get '/discovering_roof_damage', to: 'home#discovering_roof_damage', as: 'discovering_roof_damage'
  get '/expense_reimbursement', to: 'home#expense_reimbursement', as: 'expense_reimbursement'
  get '/supplier_register', to: 'home#supplier_register', as: 'supplier_register'
  get '/pickup_register', to: 'home#pickup_register', as: 'pickup_register'
  get '/disposal_configuration', to: 'home#disposal_configuration', as: 'disposal_configuration'
  get '/catalogue_setup', to: 'home#catalogue_setup', as: 'catalogue_setup'
  get '/forgot_password', to: 'home#forgot_password', as: 'forgot_password'
  get '/map', to: 'home#map', as: 'map'

  get "availability/calendar", to: "availability#calendar"

  #ajax url
  get '/custom/:selector', :to => 'home#filter_address', as: :exportFile
  get '/date/:selector', :to => 'home#filter_date'
  get '/summary/:name/:date', :to => 'home#summary', as: 'summary_select'


  resources("bookings")

  mount Spree::Core::Engine, :at => '/shop'

  Spree::Core::Engine.routes.draw do
    #get "/shops_ajax" => 'home#index', as: 'shops_ajax'
    get "/shops_ajax" => 'home#shops_ajax', as: 'shops_ajax'
  end

  end
