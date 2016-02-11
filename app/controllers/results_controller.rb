class ResultsController < ApplicationController
  def index
  end

  def new
  end

  def create
    render action: 'index'
  end
end
