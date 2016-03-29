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

  def requests_histogram_plot
    @plot_id = params[:plot_id]
    @result1_data = Result.values_of_requests(params[:result1_id], params[:label])
    @result2_data = Result.values_of_requests(params[:result2_id], params[:label])
  end

  def all_requests_histogram_plot
    @result1_data = Result.values_of_requests(params[:result1_id])
    @result2_data = Result.values_of_requests(params[:result2_id])
  end

  def percentile_requests_plot
    @result1_data = Result.percentile_of_values_of_requests(params[:result1_id])
    @result2_data = Result.percentile_of_values_of_requests(params[:result2_id])
  end

  def performance_plot
    group = params[:group]
    @unit = group[:units]
    @group_name = group[:name]
    @plot_id = params[:plot_id]
    @result1_data = Result.performance_plot(params[:result1_id], group[:labels])
    @result2_data = Result.performance_plot(params[:result2_id], group[:labels])
  end
end
