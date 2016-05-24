class RenameValueSmoothingInterval < ActiveRecord::Migration
  def change
    rename_column :results, :value_smoothing_interval, :smoothing_percent
  end
end
