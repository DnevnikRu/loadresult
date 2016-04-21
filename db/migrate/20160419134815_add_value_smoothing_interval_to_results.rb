class AddValueSmoothingIntervalToResults < ActiveRecord::Migration
  def change
    add_column :results, :value_smoothing_interval, :integer
  end
end
