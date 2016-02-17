class CompareController < ApplicationController
  def show
  end

  def request_chart
    @data = params[:data]
    @name = params[:name]
    @div_id = params[:div_id]
    respond_to do |format|
      format.js
    end
  end

  def chart_example
    @results = { # mock data
      request_chart1: {
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
      request_chart2: {
        current: {
          web00: {
            x: [1, 2, 3, 4],
            y: [23, 34, 35, 34]
          },
          web01: {
            x: [1, 2, 3, 4],
            y: [23, 26, 16, 10]
          }
        },
        base: {
          web00: {
            x: [1, 2, 3, 4],
            y: [10, 16, 13, 17]
          },
          web01: {
            x: [1, 2, 3, 4],
            y: [16, 45, 13, 9]
          }
        }
      }
    }
  end
end
