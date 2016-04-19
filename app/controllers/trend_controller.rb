class TrendController < ApplicationController
  def show
    if params[:result].nil? || params[:result].size != 2
      return redirect_to results_path, alert: 'You should select 2 results to create a trend'
    end

    results = params[:result].map do |result_id|
      Result.find_by(id: result_id)
    end

    return redirect_to(results_path, alert: "Can't find selected results") if results.include? nil
    if results.size == 2
      message = "There are only 2 results between selected results. Can't create a trend"
      return redirect_to(results_path, alert: message)
    end

    flash[:result_ids] = nil # reset choosen results on the result index page
  end
end
