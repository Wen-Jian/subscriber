class CreateFlightTickets < ActiveRecord::Migration[5.2]
  def change
    create_table :flight_tickets do |t|
      t.string :flight_company
      t.integer :price
      t.string :destination
      t.date :flight_date
      t.timestamps
    end
  end
end
