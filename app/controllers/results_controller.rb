class ResultsController < ApplicationController
  def index
    @results = Result.all
  end

  def new
  end

  def create
    result = Result.upload_and_create(params)
    if result.errors.empty?
      redirect_to({action: :index}, notice: 'Result was successfully created.')
    else
      redirect_to({action: :new}, alert: result.errors.full_messages)
    end
  end

  def compare
  end

  def request_chart
    @data = {# mock data
             current: {
                 web00: {
                     x: [1, 2, 3, 4],
                     y: [5, 10, 11, 14]
                 },
                 web01: {
                     x: [1, 2, 3, 4],
                     y: [14, 3, 7, 8]
                 }
             },
             base: {
                 web00: {
                     x: [1, 2, 3, 4],
                     y: [10, 15, 13, 17]
                 },
                 web01: {
                     x: [1, 2, 3, 4],
                     y: [16, 5, 11, 9]
                 }
             }
    }
    @name = 'Requests current'
    respond_to do |format|
      format.js
    end
  end

  def compare_chart_temp
    @data = {# mock data
             requests1: {
                 current: {
                     web00: {
                         x: [1, 2, 3, 4],
                         y: [5, 10, 11, 14]
                     },
                     web01: {
                         x: [1, 2, 3, 4],
                         y: [14, 3, 7, 8]
                     }
                 },
                 base: {
                     web00: {
                         x: [1, 2, 3, 4],
                         y: [10, 15, 13, 17]
                     },
                     web01: {
                         x: [1, 2, 3, 4],
                         y: [16, 5, 11, 9]
                     }
                 }
             },
             requests2: {
                 current: {
                     web00: {
                         x: [1, 2, 3, 4],
                         y: [4, 2, 10, 8]
                     },
                     web01: {
                         x: [1, 2, 3, 4],
                         y: [10, 9, 0, 4]
                     }
                 },
                 base: {
                     web00: {
                         x: [1, 2, 3, 4],
                         y: [57, 10, 11, 13]
                     },
                     web01: {
                         x: [1, 2, 3, 4],
                         y: [10, 12, 11, 10]
                     }
                 }
             }
    }
  end
end
