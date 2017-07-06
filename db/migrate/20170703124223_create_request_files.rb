class CreateRequestFiles < ActiveRecord::Migration
  def change
    create_table :request_files do |t|
      t.string :file, null: false
    end
  end
end
