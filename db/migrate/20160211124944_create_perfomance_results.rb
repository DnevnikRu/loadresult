class CreatePerfomanceResults < ActiveRecord::Migration
  def change
    create_table :perfomance_result do |t|
      t.integer :result_id
      t.timestamp :timestamp
      t.string :label
      t.integer :value

      t.timestamps null: false
    end
  end
end
