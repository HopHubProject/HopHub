class AddStartDateToRideRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :ride_requests, :start_date, :datetime
  end
end
