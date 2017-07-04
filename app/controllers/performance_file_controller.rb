class PerformanceFileController < ApplicationController

  def create
    performance_file = PerformanceFile.new(
        file: params[:file]
    )
    performance_file.save!
    if performance_file.errors.empty?
      render json: {id: performance_file.id, url: performance_file_path(performance_file.id)}
    else
      render json: result.errors.full_messages, :status => :bad_request
    end
  end

  def show
    send_file PerformanceFile.find_by(id: params[:id]).file.current_path
  end

end