class HomeController < ApplicationController

  include Math

  def index
  end

  def our_service
  end

  def business
  end

  def custom
    customadd = "50,30"
    splcusadd = split_data(customadd)
    @Customaddress = customadd
    @Contractors = []
    @JobImgs = []
    contractall = Contractor.joins('LEFT OUTER JOIN Companyimgs ON Companyimgs.name = Contractors.name').
                  select("Contractors.*, Companyimgs.logo, Companyimgs.certi1, Companyimgs.certi2, Companyimgs.carousel")
    contractall.each do |con|
      if calc_distance(splcusadd, split_data(con.add) ) <= con.appro
        @JobImgs[con.id] = con.carousel.split(",")       
        @Contractors << con;
      end
    end
  end

  def filter_address
    pt = Contractor.where("id = #{params[:selector]}")
    respond_to do |format|
      format.js {render :json => {:result => pt} }
    end
  end

  def filter_date
    customadd = "50,30"
    requireday = 3
    splcusadd = split_data(customadd)
    date = params[:selector].split("/");
    startdate = Date.new(date[0].to_i, date[1].to_i, date[2].to_i) + requireday.days
    pt = []
    contractall = Contractor.joins('LEFT OUTER JOIN Companyimgs ON Companyimgs.name = Contractors.name').
                  select("Contractors.*, Companyimgs.logo, Companyimgs.certi1, Companyimgs.certi2, Companyimgs.carousel")
    contractall.each do |con|
      if calc_distance(splcusadd, split_data(con.address) ) <= con.appro 
        if con.servicedate >= startdate
          pt << con;
        end
      end
    end
    respond_to do |format|
      format.js {render :json => {:dateresult => pt} }
    end
  end

  def calc_distance(customer, contractor)
    radius = 6371
    lat1 = to_rad(customer[0])
    lat2 = to_rad(contractor[0])
    lon1 = to_rad(customer[1])
    lon2 = to_rad(contractor[1])
    dLat = lat2-lat1   
    dLon = lon2-lon1

    a = Math::sin(dLat/2) * Math::sin(dLat/2) +
         Math::cos(lat1) * Math::cos(lat2) * 
         Math::sin(dLon/2) * Math::sin(dLon/2);
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a));
    d = radius * c
    return d
  end

  def to_rad(angle)
    ang= angle.to_f
    angle = ang * Math::PI / 180 
    return angle
  end
  
  def split_data(data)
    spldata = data.split(",")
    return spldata
  end
  def summary
    jobImgs = []
    id = -1
    address = ''
    contractors = Contractor.joins('LEFT OUTER JOIN Companyimgs ON Companyimgs.name = Contractors.name').
                  select("Contractors.*, Companyimgs.logo, Companyimgs.certi1, Companyimgs.certi2, Companyimgs.carousel").
                  where("Contractors.name = ?", params[:name] ).
                  limit(1)
    contractors.each do |con|
      @contractor = con;
      jobImgs[con.id] = con.carousel.split(",") 
      address = con.add.split(",")  
      id = con.id
    end

    if @contractor.price
      @Deposit = @contractor.price * 0.1
    else
      @Deposit = 0
    end
    @ProductImg = jobImgs[id][0]
    @Lat = address[0]
    @Lon = address[1] 
    @Date = params[:date]
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
