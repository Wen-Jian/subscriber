class AddColumnNamedNotifyPriceToCreateFetchSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :fetch_settings, :notify_price, :integer
  end
end
