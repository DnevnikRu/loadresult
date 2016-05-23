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
    flash.now[:data_version] = @result[:data_version]
    flash.now[:test_run_date] = @result[:test_run_date].try(:strftime, '%d.%m.%Y %H:%M')
    flash.now[:time_cutting_percent] = @result[:time_cutting_percent]
    flash.now[:smoothing_percent] = @result[:smoothing_percent]
    flash.now[:release_date] = @result[:release_date].try(:strftime, '%d.%m.%Y %H:%M')
    flash.now[:comment] = @result[:comment]
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
      flash.now[:data_version] = params[:data_version]
      flash.now[:test_run_date] = params[:test_run_date]
      flash.now[:time_cutting_percent] = params[:time_cutting_percent]
      flash.now[:smoothing_percent] = params[:smoothing_percent]
      flash.now[:release_date] = params[:release_date]
      flash.now[:comment] = params[:comment]
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
      flash.now[:version] = params[:version]
      flash.now[:rps] = params[:rps]
      flash.now[:duration] = params[:duration]
      flash.now[:profile] = params[:profile]
      flash.now[:data_version] = params[:data_version]
      flash.now[:test_run_date] = params[:test_run_date]
      flash.now[:time_cutting_percent] = params[:time_cutting_percent]
      flash.now[:smoothing_percent] = params[:smoothing_percent]
      flash.now[:release_date] = params[:release_date]
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

  def performance_plot
    group = params[:group]
    @unit = group[:units]
    @group_name = group[:name]
    @plot_id = params[:plot_id]
    @result_data = Result.performance_seconds_to_values(params[:result_id], group[:labels], params[:result_time_cut].to_i)
  end

  def requests_histogram_plot
    @plot_id = params[:plot_id]
    @result_data = Result.values_of_requests(params[:result_id], params[:label], params[:result_time_cut].to_i)
  end

  def requests_seconds_to_values_plot
    @plot_id = params[:plot_id]
    @result_data = Result.requests_seconds_to_values(params[:result_id], params[:label], params[:result_time_cut].to_i)
  end

  def all_requests_histogram_plot
    @result_data = Result.values_of_requests(params[:result_id], params[:result_time_cut].to_i)
  end

  def percentile_requests_plot
    @result_data = Result.percentile_of_values_of_requests(params[:result_id], params[:result_time_cut].to_i)
  end

  private

  def set_result
    @result = Result.find_by(id: params[:id])
  end
end
