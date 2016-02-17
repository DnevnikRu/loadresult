class ChangeRequestResultTimestampType < ActiveRecord::Migration
  def change
    change_column :requests_results, :timestamp, 'bigint USING CAST(timestamp AS bigint)'
  end
end
