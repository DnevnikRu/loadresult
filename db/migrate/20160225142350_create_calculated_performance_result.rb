class CreateCalculatedPerformanceResult < ActiveRecord::Migration
  def change
    create_table :calculated_performance_results do |t|
      t.integer :result_id, null: false
      t.string :label
      t.float :mean
      t.float :max
      t.float :min
    end
  end
end
