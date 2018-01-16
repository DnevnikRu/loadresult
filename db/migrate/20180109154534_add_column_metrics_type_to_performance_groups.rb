class AddColumnMetricsTypeToPerformanceGroups < ActiveRecord::Migration
  def change
    add_column :performance_groups, :metrics_type, :integer
  end
end
