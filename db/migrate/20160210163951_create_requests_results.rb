class CreateRequestsResults < ActiveRecord::Migration
  def change
    create_table :requests_results do |t|
      t.integer :result_id
      t.timestamp :timestamp
      t.string :label
      t.integer :value
      t.integer :responce_code
      t.timestamps null: false
    end
  end
end
