class CalculateLastValue < ActiveRecord::Migration
  def change
    results = Result.where('test_run_date >= ?', DateTime.parse('2017-12-15'))
    results.each do |result|
      Result.calculate_last_value(result)
    end
  end
end
