class AddColumnFlightTypeToFetchSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :fetch_settings, :flight_type, :integer

    add_column :flight_tickets, :flight_type, :integer
  end
end
