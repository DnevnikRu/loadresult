class Api::ResultsController < ApiController
  def create
    params['project'] = Project.find_by(project_name: params['project']).try(:id)
    params['keep_files'] = 'keep' if params['keep_files'].nil?
    result = Result.upload_and_create(params)

    if result.errors.empty?
      render json: {result_id: result.id, status: 'created'}
    else
      render json: result.errors.full_messages, :status => :bad_request
    end
  end

  def index
    unless params['project'].to_s.empty?
      project_id = Project.find_by(project_name: params['project']).try(:id)
      if project_id
        results = Result.where(project_id: project_id).limit(10)
        render json: results.as_json(except: %i[requests_data performance_data])
        return
      end
    end
    render json: {}
  end
end