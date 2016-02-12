class RenameRequestsResultResponseCodeColumn < ActiveRecord::Migration
  def change
    rename_column :requests_results, :responce_code, :response_code
  end
end
