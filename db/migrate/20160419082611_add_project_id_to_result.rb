class AddProjectIdToResult < ActiveRecord::Migration
  def change
    add_column :results, :project_id, :integer
  end
end
