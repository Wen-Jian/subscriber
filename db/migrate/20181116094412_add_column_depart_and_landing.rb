class AddColumnDepartAndLanding < ActiveRecord::Migration[5.2]
  def change

    add_column :flight_tickets, :depart, :string, limit: 255
    add_column :fetch_settings, :depart, :string, limit: 255

  end
end
