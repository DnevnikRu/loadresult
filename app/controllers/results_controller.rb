class ResultsController < ApplicationController
  # protect_from_forgery with: :reset_session

  before_action :set_result, only: [:show, :edit, :update, :destroy]

  def index
    @results = Result.order(test_run_date: :desc).page params[:page]
    @checked_results = session[:result_ids]
  end

  def show
  end

  def new
  end

  def edit
    flash[:version] = @result[:version]
    flash[:rps] = @result[:rps]
    flash[:duration] = @result[:duration]
    flash[:profile] = @result[:profile]
    flash[:time_cutting_percent] = @result[:time_cutting_percent]
  end

  def update
    update_result = Result.update_and_recalculate(@result, params)
    if update_result
      redirect_to(results_url, notice: 'Result was successfully updated.')
    else
      flash[:version] = params[:version]
      flash[:rps] = params[:rps]
      flash[:duration] = params[:duration]
      flash[:profile] = params[:profile]
      flash[:time_cutting_percent] = params[:time_cutting_percent]
      redirect_to({ action: :edit }, alert: @result.errors.full_messages)
    end
  end

  def create
    result = Result.upload_and_create(params)
    if result.errors.empty?
      if request.content_type =~ /json/
        render json: { result_id: result.id, status: 'created' }
      else
        redirect_to(results_url, notice: 'Result was successfully created.')
       end
    else
      if request.content_type =~ /json/
        render json: result.errors.full_messages
      else
        flash[:version] = result[:version]
        flash[:rps] = result[:rps]
        flash[:duration] = result[:duration]
        flash[:profile] = result[:profile]
        flash[:test_run_date] = result[:test_run_date].try(:strftime, '%d.%m.%Y %H:%M')
        flash[:time_cutting_percent] = result[:time_cutting_percent]
        redirect_to({ action: :new }, alert: result.errors.full_messages)
      end
    end
  end

  def destroy
    @result.destroy
    redirect_to results_url, notice: 'Result was successfully destroyed.'
  end

  def toggle
    session[:result_ids] ||= []
    if session[:result_ids].include? params[:result_id]
      session[:result_ids].delete params[:result_id]
    else
      session[:result_ids].push params[:result_id]
    end
    @checked_results = session[:result_ids]

    respond_to do |format|
      format.js
    end
  end

  private

  def set_result
    @result = Result.find(params[:id])
  end
end
