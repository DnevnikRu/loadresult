class ChangePerformanceResultTimestampType < ActiveRecord::Migration
  def change
    change_column :performance_results, :timestamp, 'bigint USING CAST(timestamp AS bigint)'
  end
end
