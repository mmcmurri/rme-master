class AvailabilityController < ApplicationController
  def calendar
    if params[:booking]
      @booking = Booking.find(params[:booking])
    else
      @booking = Booking.new
    end
    @bookings = Booking.all
  end
end

