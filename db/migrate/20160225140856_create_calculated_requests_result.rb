class CreateCalculatedRequestsResult < ActiveRecord::Migration
  def change
    create_table :calculated_requests_results do |t|
      t.integer :result_id, null: false
      t.string :label
      t.float :mean
      t.float :median
      t.float :ninety_percentile
      t.float :max
      t.float :min
      t.float :throughput
      t.float :failed_results
    end
  end
end
