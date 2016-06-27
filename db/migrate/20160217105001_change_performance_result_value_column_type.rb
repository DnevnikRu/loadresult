class ChangePerformanceResultValueColumnType < ActiveRecord::Migration
  def change
    change_column :performance_results, :value, :integer, :limit => 8
  end
end
