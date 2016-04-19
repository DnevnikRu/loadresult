class TrendController < ApplicationController
  def show
    if params[:result].nil? || params[:result].size == 1
      return redirect_to results_path, alert: 'You should select 2 or more results to create a trend'
    end

    results = params[:result].map do |result_id|
      Result.find_by(id: result_id)
    end
    return redirect_to(results_path, alert: "Can't find selected results") if results.include? nil
    return redirect_to(results_path, alert: "Can't create a trend for 2 results") if results.size == 2

    flash[:result_ids] = nil # reset choosen results on the result index page
  end
end
