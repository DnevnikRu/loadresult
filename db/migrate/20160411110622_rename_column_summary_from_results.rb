class RenameColumnSummaryFromResults < ActiveRecord::Migration
  def change
    rename_column :results, :summary, :requests_data
  end
end
