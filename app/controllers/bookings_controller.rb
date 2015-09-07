class BookingsController < ApplicationController
  def create
    @booking = Booking.new(booking_params)

    if @booking.save
      flash[:notice] = "Successfully created booking"
    else
      flash[:notice] = "Failed to create booking!"
    end

    redirect_to(availability_calendar_path)
  end

  def update
    @booking = Booking.find(params[:id])

    if @booking.update(booking_params)
      flash[:notice] = "Successfully update booking"
    else
      flash[:notice] = "Failed to update booking!"
    end

    redirect_to(availability_calendar_path)
  end

private
  def booking_params
    params.require(:booking).permit(
      :id, :date, :team_size, :address, :city, :country, :customer_name,
      :phone_number, :source
    )
  end
end

