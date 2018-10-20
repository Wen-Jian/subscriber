class CreateFetchSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :fetch_settings do |t|
      t.string :destination
      t.boolean :revoke, default: false
      t.timestamps
    end
  end
end
