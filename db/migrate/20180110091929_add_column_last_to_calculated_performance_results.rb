class AddColumnLastToCalculatedPerformanceResults < ActiveRecord::Migration
  def change
    add_column :calculated_performance_results, :last_value, :float
  end
end
