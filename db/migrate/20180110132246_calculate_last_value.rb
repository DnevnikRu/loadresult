class CalculateLastValue < ActiveRecord::Migration
  def change
    results = Result.where('test_run_date >= ?', DateTime.parse('2018-07-12'))
    results.each do |result|
      Result.calculate_last_value(result)
    end
  end
end
