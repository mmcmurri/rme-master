class Booking < ActiveRecord::Base
  validates(
    :date, :team_size, :address, :city, :country, :customer_name,
    :phone_number, :source, presence: true
  )
end

