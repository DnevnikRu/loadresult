require 'pathname'


class Api::ResultsWithDataIdController < ApiController

  def create
    params['project'] = Project.find_by(project_name: params['project']).try(:id)
    if params['request_file_id']
      request_file = RequestFile.find_by(id: params['request_file_id'].to_i)
      if request_file
        params['requests_data'] = get_data(request_file.file)
      else
        render json: "can`t find request file with id #{params['request_file_id']}", :status => :bad_request and return
      end
    else
      render json: 'request_file_id is required', :status => :bad_request and return
    end

    if params['perfmon_file_id']
      perfmon_file = PerformanceFile.find_by(id: params['perfmon_file_id'].to_i)
      if perfmon_file
        params['performance_data'] = get_data(perfmon_file.file)
      else
        render json: "can`t find performance file with id #{params['perfmon_file_id']}", :status => :bad_request and return
      end
    end

    result = Result.upload_and_create(params)

    if result.errors.empty?
      render json: {result_id: result.id, status: 'created'}
    else
      render json: result.errors.full_messages, :status => :bad_request
    end
  end

  def get_data(file)
    tempfile = Tempfile.new('file')
    tempfile.binmode
    tempfile.write(File.read(file.current_path))
    tempfile.rewind
    mime_type = Mime::Type.lookup_by_extension(File.extname(file.current_path)[1..-1]).to_s
    ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile, :filename => Pathname.new(file.current_path).basename.to_s, :type => mime_type)
  end

end