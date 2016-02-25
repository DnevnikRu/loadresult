class CompareController < ApplicationController
  def show
    if params[:result].nil? || params[:result].size == 1
      return redirect_to results_path, alert: 'You should select 2 or more results to compare them'
    end
    result1 = Result.find_by(id: params[:result][0])
    result2 = Result.find_by(id: params[:result][1])
    if result1.nil? || result2.nil?
      return redirect_to results_path, alert: "Can't find selected results"
    end
    @compare_report = CompareReport.new(result1, result2)
  end

  def histogram_requests_plot
    @div_id = params[:div_id]
    label = params[:label]
    result1_id = params[:result1_id]
    result2_id = params[:result2_id]
    @result1_data = RequestsResult.where(result_id: result1_id, label: label).map(&:value)
    @result2_data = RequestsResult.where(result_id: result2_id, label: label).map(&:value)
  end
end
