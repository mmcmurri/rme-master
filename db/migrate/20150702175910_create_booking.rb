class CreateBooking < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.date :date
      t.integer :team_size
      t.text :address
      t.text :city
      t.text :country
      t.text :customer_name
      t.text :phone_number
      t.text :source
    end
  end
end
