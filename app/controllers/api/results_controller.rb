class Api::ResultsController < ApiController
  def create
    project_id = Project.where(project_name: params['project']).pluck(:id).join(" ")
    if project_id.blank?
      render json: ['Project undefined'], :status => :bad_request
      return
    else
      params['project'] = project_id.to_s
    end
    result = Result.upload_and_create(params)

    if result.errors.empty?
      render json: {result_id: result.id, status: 'created'}
    else
      render json: result.errors.full_messages, :status => :bad_request
    end
  end
end