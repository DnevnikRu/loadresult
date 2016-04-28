class ResultsController < ApplicationController
  before_action :set_result, only: [:show, :edit, :update, :destroy, :download_requests_data, :download_performance_data, :report]

  def index
    @results = Result.order(test_run_date: :desc).page params[:page]
    flash.keep(:result_ids)
    @checked_results = flash[:result_ids]
  end

  def show
  end

  def new
  end

  def edit
    flash.now[:version] = @result[:version]
    flash.now[:rps] = @result[:rps]
    flash.now[:duration] = @result[:duration]
    flash.now[:profile] = @result[:profile]
    flash.now[:time_cutting_percent] = @result[:time_cutting_percent]
    flash.now[:value_smoothing_interval] = @result[:value_smoothing_interval]
    flash.now[:release_date] = @result[:release_date]
    flash.now[:requests_data_identifier] = @result.requests_data_identifier
    flash.now[:performance_data_identifier] = @result.performance_data_identifier
  end

  def update
    result = Result.update_and_recalculate(@result, params)
    if result.errors.empty?
      redirect_to(results_url, notice: 'Result was successfully updated.')
    else
      flash.now[:version] = params[:version]
      flash.now[:rps] = params[:rps]
      flash.now[:duration] = params[:duration]
      flash.now[:profile] = params[:profile]
      flash.now[:time_cutting_percent] = params[:time_cutting_percent]
      flash.now[:value_smoothing_interval] = params[:value_smoothing_interval]
      flash.now[:release_date] = @result[:release_date]
      flash.now[:requests_data_identifier] = @result.requests_data_identifier
      flash.now[:performance_data_identifier] = @result.performance_data_identifier
      flash.now[:alert] = result.errors.full_messages
      render action: :edit
    end
  end

  def create
    result = Result.upload_and_create(params)
    if result.errors.empty?
      redirect_to(results_url, notice: 'Result was successfully created.')
    else
      flash.now[:version] = result[:version]
      flash.now[:rps] = result[:rps]
      flash.now[:duration] = result[:duration]
      flash.now[:profile] = result[:profile]
      flash.now[:test_run_date] = result[:test_run_date].try(:strftime, '%d.%m.%Y %H:%M')
      flash.now[:time_cutting_percent] = result[:time_cutting_percent]
      flash.now[:value_smoothing_interval] = params[:value_smoothing_interval]
      flash.now[:alert] = result.errors.full_messages
      render action: :new
    end
  end

  def destroy
    @result.destroy
    redirect_to results_url, notice: 'Result was successfully destroyed.'
  end

  def toggle
    flash[:result_ids] ||= []
    if flash[:result_ids].include? params[:result_id]
      flash[:result_ids].delete params[:result_id]
    else
      flash[:result_ids].push params[:result_id]
    end
    flash.keep(:result_ids)
    @checked_results = flash[:result_ids]

    respond_to do |format|
      format.js
    end
  end

  def download_requests_data
    send_file @result.requests_data.current_path
  end

  def download_performance_data
    send_file @result.performance_data.current_path
  end

  def report

  end

  private

  def set_result
    @result = Result.find_by(id: params[:id])
  end
end
