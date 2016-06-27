class ChangeResultsRpsTypeToString < ActiveRecord::Migration
  def change
    change_column :results, :rps, :string
  end
end
