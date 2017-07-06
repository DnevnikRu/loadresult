class CreatePerformanceFiles < ActiveRecord::Migration
  def change
    create_table :performance_files do |t|
      t.string :file, null: false
    end
  end
end
