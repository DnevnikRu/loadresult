class ChangeColumnNameGroupId < ActiveRecord::Migration
  def change
    rename_column :performance_labels, :group_id, :performance_group_id
  end
end
