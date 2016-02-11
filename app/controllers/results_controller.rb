class ResultsController < ApplicationController
  def index
    @results = Result.all
  end

  def new
  end

  def create
    if rand(1..2) == 1
      redirect_to({action: :index}, notice: 'Result was successfully created.')
    else # error
      @errors = ['first error', 'second error', 'third error']
      redirect_to({action: :new}, alert: @errors)
    end
  end

end
