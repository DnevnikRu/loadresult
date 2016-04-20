class AddColumnReleaseDateToResult < ActiveRecord::Migration
  def change
    add_column :results, :release_date, :datetime
  end
end
