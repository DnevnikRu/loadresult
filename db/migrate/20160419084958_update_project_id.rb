class UpdateProjectId < ActiveRecord::Migration
  def change
    Result.where(project_id: nil).update_all(project_id: 1)
  end
end
