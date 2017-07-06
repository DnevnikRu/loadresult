class RequestFileController < ApplicationController

  protect_from_forgery with: :null_session

  def create
    request_file = RequestFile.new(
        file: params[:file]
    )
    request_file.save!
    if request_file.errors.empty?
      render json: {id: request_file.id, url: "/request_file/#{request_file.id}"}
    else
      render json: result.errors.full_messages, :status => :bad_request
    end
  end

  def show
    send_file RequestFile.find_by(id: params[:id]).file.current_path
  end

end