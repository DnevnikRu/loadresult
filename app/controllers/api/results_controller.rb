class Api::ResultsController < ApiController
  def create
    result = Result.upload_and_create(params)

    if result.errors.empty?
      render json: {result_id: result.id, status: 'created'}
    else
      render json: result.errors.full_messages, :status => :bad_request
    end
  end
end