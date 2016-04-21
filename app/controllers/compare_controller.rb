class CompareController < ApplicationController
  def show
    flash.keep(:result_ids)
    if params[:result].nil? || params[:result].size == 1
      return redirect_to results_path, alert: 'You should select 2 or more results to compare them'
    end
    result1 = Result.find_by(id: params[:result][0])
    result2 = Result.find_by(id: params[:result][1])
    if result1.nil? || result2.nil?
      return redirect_to results_path, alert: "Can't find selected results"
    end
    flash[:result_ids] = nil # reset choosen results on the result index page

    @compare_report = CompareReport.new(result1, result2)
  end

  def requests_histogram_plot
    @plot_id = params[:plot_id]
    @result1_data = Result.values_of_requests(params[:result1_id], params[:label], params[:result1_time_cut].to_i)
    @result2_data = Result.values_of_requests(params[:result2_id], params[:label], params[:result2_time_cut].to_i)
  end

  def requests_seconds_to_values_plot
    @plot_id = params[:plot_id]
    @result1_data = Result.requests_seconds_to_values(params[:result1_id], params[:label], params[:result1_time_cut].to_i)
    @result2_data = Result.requests_seconds_to_values(params[:result2_id], params[:label], params[:result2_time_cut].to_i)
  end

  def all_requests_histogram_plot
    @result1_data = Result.values_of_requests(params[:result1_id], params[:result1_time_cut].to_i)
    @result2_data = Result.values_of_requests(params[:result2_id], params[:result2_time_cut].to_i)
  end

  def percentile_requests_plot
    @result1_data = Result.percentile_of_values_of_requests(params[:result1_id], params[:result1_time_cut].to_i)
    @result2_data = Result.percentile_of_values_of_requests(params[:result2_id], params[:result2_time_cut].to_i)
  end

  def performance_plot
    group = params[:group]
    @unit = group[:units]
    @group_name = group[:name]
    @plot_id = params[:plot_id]
    @result1_data = Result.performance_seconds_to_values(params[:result1_id], group[:labels], params[:result1_time_cut].to_i)
    @result2_data = Result.performance_seconds_to_values(params[:result2_id], group[:labels], params[:result1_time_cut].to_i)
  end
end
