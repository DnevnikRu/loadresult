class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.string :version, null: false
      t.integer :duration, null: false
      t.integer :rps, null: false
      t.string :profile, null: false
      t.datetime :test_run_date, null: false

      t.timestamps null: false
    end
  end
end
