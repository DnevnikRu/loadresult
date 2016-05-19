class TrendController < ApplicationController
  def show
    flash.keep(:result_ids)
    if params[:result].nil? || params[:result].size != 2
      return redirect_to results_path, alert: 'You should select 2 results to create a trend'
    end

    @trend_report = TrendReport.new(params[:result][0], params[:result][1])
    if @trend_report.error
      return redirect_to results_path, alert: @trend_report.error
    end
    flash[:result_ids] = nil # reset choosen results on the result index page
  end

  def requests_plot
    label = params[:label]
    id_from = params[:id_from]
    id_to = params[:id_to]

    trend_report = TrendReport.new(id_from, id_to)
    @ids_with_date = trend_report.ids_with_date
    @request_data = trend_report.request_data(label)
  end

  def performance_plot
    group_name = params[:group_name]
    id_from = params[:id_from]
    id_to = params[:id_to]

    trend_report = TrendReport.new(id_from, id_to)
    group = trend_report.performance_groups.find { |group| group[:name] == group_name }
    @ids_with_date = trend_report.ids_with_date
    @group_name = group[:name]
    @unit = group[:units]
    @performance_data = trend_report.performance_data(group[:labels])
  end

  def all_requests_stats_plot
    @plot_id = params[:plot_id]
    id_from = params[:id_from]
    id_to = params[:id_to]

    trend_report = TrendReport.new(id_from, id_to)
    @ids_with_date = trend_report.ids_with_date
    @request_data = trend_report.request_data('all_requests')
  end
end
