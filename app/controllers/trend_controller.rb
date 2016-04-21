class TrendController < ApplicationController
  def show
    flash.keep(:result_ids)
    if params[:result].nil? || params[:result].size != 2
      return redirect_to results_path, alert: 'You should select 2 results to create a trend'
    end

    results = params[:result].map { |result_id| Result.find_by(id: result_id) }
    return redirect_to(results_path, alert: "Can't find selected results") if results.include? nil

    results.sort_by!(&:test_run_date)
    results_between = Result.where(test_run_date: (results[0].test_run_date..results[1].test_run_date))
    if results_between.size == 2
      message = "There are only 2 results between selected results. Can't create a trend"
      return redirect_to(results_path, alert: message)
    end

    flash[:result_ids] = nil # reset choosen results on the result index page

    @trend_report = TrendReport.new(results_between.sort_by(&:test_run_date))
  end
end
