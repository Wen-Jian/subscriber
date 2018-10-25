class AddColumnToFetchSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :fetch_settings, :start_date, :date
    add_column :fetch_settings, :end_date, :date
  end
end
