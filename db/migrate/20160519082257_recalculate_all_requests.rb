class RecalculateAllRequests < ActiveRecord::Migration
  def change
    results = Result.where.not('results.id' => Result.select('id').joins(:calculated_requests_results).where(calculated_requests_results: {label: 'all_requests'}))
    results.each do |result|
      bottom_timestamp, top_timestamp = Result.border_timestamps(result.id, RequestsResult, result.time_cutting_percent)
      Result.calc_all_request_data(result, bottom_timestamp, top_timestamp)
    end
  end
end
