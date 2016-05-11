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
end
