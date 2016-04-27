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
    @plot_id = params[:plot_id]
    label = params[:label]
    ids = params[:ids].map(&:to_i)

    data = {}
    attributes = [:mean, :median, :ninety_percentile, :throughput]
    attributes.each { |at| data[at] = [] }
    ids.each do |id|
      calc_result = CalculatedRequestsResult.find_by(result_id: id, label: label)
      attributes.each { |at| data[at].push calc_result.send(at) }
    end

    @ids = ids.map { |id| "id:#{id}\n#{Result.find_by(id: id).release_date.to_date}" }
    @data = data
  end
end
