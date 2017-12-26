class AddColumnNinetyninePercentile < ActiveRecord::Migration
  def change
    add_column :calculated_requests_results, :ninetynine_percentile, :float
  end
end
