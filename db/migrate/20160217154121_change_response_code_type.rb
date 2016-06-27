class ChangeResponseCodeType < ActiveRecord::Migration
  def change
    change_column :requests_results, :response_code, :string
  end
end
