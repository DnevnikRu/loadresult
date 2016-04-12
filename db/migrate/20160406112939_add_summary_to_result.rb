class AddSummaryToResult < ActiveRecord::Migration
  def change
    add_column :results, :summary, :string
  end
end
