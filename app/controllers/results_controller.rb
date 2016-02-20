class ResultsController < ApplicationController
  def index
    @results = Result.all
  end

  def new
  end

  def create
    result = Result.upload_and_create(params)
    if result.errors.empty?
      redirect_to({ action: :index }, notice: 'Result was successfully created.')
    else
      flash[:version] = result[:version]
      flash[:rps] = result[:rps]
      flash[:duration] = result[:duration]
      flash[:profile] = result[:profile]
      flash[:test_run_date] = result[:test_run_date].try(:strftime, '%d.%m.%Y %H:%M')
      redirect_to({ action: :new }, alert: result.errors.full_messages)
    end
  end
end
