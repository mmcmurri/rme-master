class HomeController < ApplicationController
  
  def index
  end

  def our_service
  end

  def business
  end

  def custom
    @Contractors = Contractor.joins('LEFT OUTER JOIN Companyimgs ON Companyimgs.name = Contractors.name').select("Contractors.*, Companyimgs.logo, Companyimgs.certi1, Companyimgs.certi2, Companyimgs.carousel")
  end

  def getselector
    pt = Contractor.where("id = #{params[:selector]}")
    respond_to do |format|
      format.js {render :json => {:result => pt} }
    end
  end

  def login_portal
  end

  def availablity_calendar
  end

  def contact_us
  end

  def customer_information
  end

  def file_complaint
  end

  def forms_submissions_home
  end

  def register
  end

  def site_damage
  end

  def discovering_roof_damage
  end

  def supplier_register
  end

  def pickup_register
  end

  def disposal_configuration
  end

  def catalogue_setup
  end

  def expense_reimbursement
  end

  def forgot_password
  end

end
