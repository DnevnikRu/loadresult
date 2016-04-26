class TrendController < ApplicationController
  def show
    flash.keep(:result_ids)
    if params[:result].nil? || params[:result].size != 2
      return redirect_to results_path, alert: 'You should select 2 results to create a trend'
    end

    result1 = Result.find_by(id: params[:result][0])
    result2 = Result.find_by(id: params[:result][1])

    if result1.nil? || result2.nil?
      return redirect_to results_path, alert: "Can't find selected results"
    end

    if result1.project_id != result2.project_id
      return redirect_to results_path, alert: "Can't create a trend with results in different projects"
    end

    if result1.release_date.nil? || result2.release_date.nil?
      return redirect_to results_path, alert: "Can't create a trend with results without release date"
    end

    results = [result1, result2].sort_by(&:release_date)
    results_between = Result.where(
      release_date: (results[0].release_date..results[1].release_date),
      project_id: result1.project_id
    )
    if results_between.size == 2
      message = "There are only 2 results between selected results. Can't create a trend"
      return redirect_to results_path, alert: message
    end

    flash[:result_ids] = nil # reset choosen results on the result index page

    @trend_report = TrendReport.new(results_between.sort_by(&:release_date))
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

    @ids = ids
    @data = data
  end
end
