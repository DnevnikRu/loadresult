class RecalculateWithNinetyninePercentile < ActiveRecord::Migration
  def change
    Result.all.each do |result|
      labels = CalculatedRequestsResult.where(:result_id => result.id).pluck(:label)
      labels.each do |label|
        Result.calc_ninetynine_percentile(result, label)
      end
    end
  end
end
