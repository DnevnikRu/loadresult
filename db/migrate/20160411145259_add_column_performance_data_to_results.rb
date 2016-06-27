class AddColumnPerformanceDataToResults < ActiveRecord::Migration
  def change
    add_column :results, :performance_data, :string
  end
end
