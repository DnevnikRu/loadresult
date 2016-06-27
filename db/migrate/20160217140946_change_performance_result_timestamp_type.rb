class ChangePerformanceResultTimestampType < ActiveRecord::Migration
  def change
    remove_column :performance_results, :timestamp
    add_column :performance_results, :timestamp, :integer, limit: 8
  end
end
