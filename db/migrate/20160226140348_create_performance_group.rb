class CreatePerformanceGroup < ActiveRecord::Migration
  def change
    create_table :performance_groups do |t|
      t.string :name
      t.string :units
      t.float :trend_limit
    end
  end
end
