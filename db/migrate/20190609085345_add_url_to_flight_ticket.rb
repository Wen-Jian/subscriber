class AddUrlToFlightTicket < ActiveRecord::Migration[5.2]
  def change
    add_column :flight_tickets, :url, :string
  end
end
