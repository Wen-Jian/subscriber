class AddColumnNotifiedPriceToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :fetch_settings, :notified_price, :integer
  end
end
