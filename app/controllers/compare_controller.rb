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
    session[:result_ids] = [] # reset choosen results on the result index page
    @warnings = find_differences(result1, result2)
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

  private

  def find_differences(result1, result2)
    warnings = []
    warnings += find_description_differences(result1, result2)
    warnings += find_label_differences(result1, result2)
    warnings
  end

  def find_description_differences(result1, result2)
    warnings = []
    template = "%s: id:%d has '%s' but id:%d has '%s'"
    description_to_check = {
      duration: 'Duration',
      rps: 'Rps',
      profile: 'Profile',
      time_cutting_percent: 'Time cutting percent'
    }
    description_to_check.each do |field, field_name|
      result1_value = result1.send(field)
      result2_value = result2.send(field)
      if result1_value != result2_value
        warnings.push template % [field_name, result1.id, result1_value, result2.id, result2_value]
      end
    end
    warnings
  end

  def find_label_differences(result1, result2)
    warnings = []
    template = 'id:%d has extra %s labels: %s'
    result1_perf_labels = result1.calculated_performance_results.pluck(:label).uniq
    result2_perf_labels = result2.calculated_performance_results.pluck(:label).uniq
    result1_request_labels = result1.calculated_requests_results.pluck(:label).uniq
    result2_request_labels = result2.calculated_requests_results.pluck(:label).uniq
    result1_extra_perf_labels = result1_perf_labels - result2_perf_labels
    result2_extra_perf_labels = result2_perf_labels - result1_perf_labels
    result1_extra_request_labels = result1_request_labels - result2_request_labels
    result2_extra_request_labels = result2_request_labels - result1_request_labels
    if result1_extra_perf_labels.any?
      warnings.push template % [result1.id, 'performance', join_with_quotes(result1_extra_perf_labels)]
    end
    if result2_extra_perf_labels.any?
      warnings.push template % [result2.id, 'performance', join_with_quotes(result2_extra_perf_labels)]
    end
    if result1_extra_request_labels.any?
      warnings.push template % [result1.id, 'request', join_with_quotes(result1_extra_request_labels)]
    end
    if result2_extra_request_labels.any?
      warnings.push template % [result2.id, 'request', join_with_quotes(result2_extra_request_labels)]
    end
    warnings
  end

  def join_with_quotes(arr)
    %('#{arr.join("', '")}')
  end
end
