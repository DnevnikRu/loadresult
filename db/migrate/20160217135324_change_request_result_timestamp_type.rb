class ChangeRequestResultTimestampType < ActiveRecord::Migration
  def change
    change_column :requests_results, :timestamp, :integer, :limit => 8
  end
end
