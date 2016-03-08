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
    @result1_data = data_for_requests_histogram_plot(params[:result1_id], params[:label])
    @result2_data = data_for_requests_histogram_plot(params[:result2_id], params[:label])
  end

  def data_for_requests_histogram_plot(result_id, label)
    bottom_timestamp, top_timestamp = Result.border_timestamps(result_id, RequestsResult)
    records = RequestsResult.where(Result.where_conditional(result_id, label, bottom_timestamp, top_timestamp))
    records.map(&:value)
  end

  def all_requests_histogram_plot
    @result1_data = data_for_all_requests_histogram_plot(params[:result1_id])
    @result2_data = data_for_all_requests_histogram_plot(params[:result2_id])
  end

  def data_for_all_requests_histogram_plot(result_id)
    bottom_timestamp, top_timestamp = Result.border_timestamps(result_id, RequestsResult)
    records = RequestsResult.where(Result.where_conditional(result_id, nil, bottom_timestamp, top_timestamp))
    records.map(&:value)
  end

  def percentile_requests_plot
    @result1_data = data_for_percentile_requests_plot(params[:result1_id])
    @result2_data = data_for_percentile_requests_plot(params[:result2_id])
  end

  def data_for_percentile_requests_plot(result_id)
    bottom_timestamp, top_timestamp = Result.border_timestamps(result_id, RequestsResult)
    records = RequestsResult.where(Result.where_conditional(result_id, nil, bottom_timestamp, top_timestamp))
    values = records.map(&:value)
    (0..100).map { |i| Result.percentile(values, i) }
  end

  def performance_plot
    @group_name = params[:group_name]
    @plot_id = params[:plot_id]
    @result1_data = data_for_performance_plot(params[:result1_id])
    @result2_data = data_for_performance_plot(params[:result2_id])
  end

  def data_for_performance_plot(result_id)
    result_data = {}
    PerformanceGroup.find_by(name: @group_name).labels.each do |label_main|
      label_main_label = label_main.label.gsub('\\') { '\\\\' }
      labels = PerformanceResult.where('label LIKE ?', "%#{label_main_label}%").pluck(:label).uniq
      labels.each do |label|
        result_data[label] = { seconds: [], values: [] }
        bottom_timestamp, top_timestamp = Result.border_timestamps(result_id, PerformanceResult)
        records = PerformanceResult.where(Result.where_conditional(result_id, label, bottom_timestamp, top_timestamp))
        min_timestamp = records.minimum(:timestamp)
        records.each do |record|
          result_data[label][:seconds].push record.timestamp - min_timestamp
          result_data[label][:values].push record.value
        end
      end
    end
    result_data
  end
end
