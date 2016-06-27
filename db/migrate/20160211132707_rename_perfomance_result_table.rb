class RenamePerfomanceResultTable < ActiveRecord::Migration
  def change
    rename_table :perfomance_result, :perfomance_results
  end
end
