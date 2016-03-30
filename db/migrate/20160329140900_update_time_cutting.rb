class UpdateTimeCutting < ActiveRecord::Migration
  def change
    Result.where(time_cutting_percent: nil).update_all(time_cutting_percent: 10)
  end
end
