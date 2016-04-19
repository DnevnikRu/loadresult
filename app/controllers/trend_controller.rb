class TrendController < ApplicationController
  def show
    flash[:result_ids] = nil # reset choosen results on the result index page
  end
end
