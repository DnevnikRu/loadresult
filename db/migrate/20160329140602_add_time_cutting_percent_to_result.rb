class AddTimeCuttingPercentToResult < ActiveRecord::Migration
  def change
    add_column :results, :time_cutting_percent, :integer
  end
end
