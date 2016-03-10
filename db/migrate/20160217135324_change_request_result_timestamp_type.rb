class ChangeRequestResultTimestampType < ActiveRecord::Migration
  def change
    remove_column :requests_results, :timestamp
    add_column :requests_results, :timestamp, :integer, limit: 8
  end
end
