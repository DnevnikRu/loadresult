class ResultsController < ApplicationController
  before_action :set_result, only: [:edit, :update, :destroy]

  def index
    @results = Result.all
  end

  def new
  end

  def edit
    flash[:version] = @result[:version]
    flash[:rps] = @result[:rps]
    flash[:duration] = @result[:duration]
    flash[:profile] = @result[:profile]
  end

  def update
    update_result = @result.update(
        version: params[:version],
        rps: params[:rps],
        duration: params[:duration],
        profile: params[:profile]
    )
    if update_result
      redirect_to(results_url, notice: 'Result was successfully updated.')
    else
      flash[:version] = params[:version]
      flash[:rps] = params[:rps]
      flash[:duration] = params[:duration]
      flash[:profile] = params[:profile]
      redirect_to({ action: :edit }, alert: @result.errors.full_messages)
    end
  end

  def create
    result = Result.upload_and_create(params)
    if result.errors.empty?
      redirect_to(results_url, notice: 'Result was successfully created.')
    else
      flash[:version] = result[:version]
      flash[:rps] = result[:rps]
      flash[:duration] = result[:duration]
      flash[:profile] = result[:profile]
      flash[:test_run_date] = result[:test_run_date].try(:strftime, '%d.%m.%Y %H:%M')
      redirect_to({ action: :new }, alert: result.errors.full_messages)
    end
  end

  def destroy
    @result.destroy
    redirect_to results_url, notice: 'Result was successfully destroyed.'
  end

  private

  def set_result
    @result = Result.find(params[:id])
  end
end
