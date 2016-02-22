class CompareController < ApplicationController
  def show
    result1 = Result.find_by(id: params[:result][0])
    result2 = Result.find_by(id: params[:result][1])
    redirect_to root_path, alert: "Can't find selected results" if result1.nil? || result2.nil?
    @compare_report = CompareReport.new(result1, result2)
  end

  def request_chart
    @data = mock_data[params[:data_name].to_sym]
    @chart_name = params[:chart_name]
    @div_id = params[:div_id]
  end

  def mock_data
    {
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
