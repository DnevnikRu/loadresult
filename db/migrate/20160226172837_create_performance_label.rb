class CreatePerformanceLabel < ActiveRecord::Migration
  def change
    create_table :performance_labels do |t|
      t.integer :group_id
      t.string :label
    end
  end
end
