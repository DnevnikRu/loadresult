class ChangeRequestResultValueColumnType < ActiveRecord::Migration
  def change
    change_column :requests_results, :value, :integer, :limit => 8
  end
end

