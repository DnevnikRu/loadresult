class ResultsController < ApplicationController
  def index
  end

  def new
  end

  def create
    version = params[:version]
    rps = params[:rps]
    duration = params[:duration]
    profile = params[:profile]
    date = params[:date]
    reqests_data = params[:reqests_data]
    perfmon_data = params[:perfmon_data]

    render action: 'index'
  end
end
