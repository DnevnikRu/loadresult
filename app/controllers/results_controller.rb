class ResultsController < ApplicationController
  def index
    @results = Result.all
  end

  def new
  end

  def create
    redirect_to({action: :index}, notice: 'Result was successfully created.')
  end
end
