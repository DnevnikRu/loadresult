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
      redirect_to({ action: :new }, alert: result.errors.full_messages)
    end
  end
end
