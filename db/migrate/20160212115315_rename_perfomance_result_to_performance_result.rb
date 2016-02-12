class RenamePerfomanceResultToPerformanceResult < ActiveRecord::Migration
  def change
    rename_table :perfomance_results, :performance_results
  end
end
