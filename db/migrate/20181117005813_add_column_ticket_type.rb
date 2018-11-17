class AddColumnTicketType < ActiveRecord::Migration[5.2]
  def change
    add_column :fetch_settings, :ticket_type, :integer
  end
end
