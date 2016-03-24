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
    @result1_data = Result.requests_histogram_plot(params[:result1_id], params[:label])
    @result2_data = Result.requests_histogram_plot(params[:result2_id], params[:label])
  end

  def all_requests_histogram_plot
    @result1_data = Result.all_requests_histogram_plot(params[:result1_id])
    @result2_data = Result.all_requests_histogram_plot(params[:result2_id])
  end

  def percentile_requests_plot
    @result1_data = Result.percentile_requests_plot(params[:result1_id])
    @result2_data = Result.percentile_requests_plot(params[:result2_id])
  end

  def performance_plot
    @group_name = params[:group_name]
    performance_group = PerformanceGroup.find_by(name: params[:group_name])
    @unit = performance_group.units
    @plot_id = params[:plot_id]
    @result1_data = Result.performance_plot(params[:result1_id], performance_group)
    @result2_data = Result.performance_plot(params[:result2_id], performance_group)
  end
end
