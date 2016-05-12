class AddDataVersionToResults < ActiveRecord::Migration
  def change
    add_column :results, :data_version, :string
  end
end
