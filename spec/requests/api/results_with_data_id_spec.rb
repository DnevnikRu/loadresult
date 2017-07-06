require 'rails_helper'

describe 'Results API with data id instead of base64 files', type: :request do
  let(:summary_file_path) { File.join(fixture_path, 'summary.csv') }
  let(:perfmon_file_path) { File.join(fixture_path, 'perfmon.csv') }
  let(:summary_file_name) { File.basename(summary_file) }
  let(:perfmon_file_name) { File.basename(perfmon_file) }

  before { DatabaseCleaner.clean }

  it 'upload request file and create result' do
    post '/request_file', :file => Rack::Test::UploadedFile.new(summary_file_path, 'text/csv')
    request_file_id = JSON.parse(response.body)['id']
    project = create(:project)
    params = {
        project: project.project_name,
        version: 'version3',
        duration: '123',
        rps: '123',
        profile: '123',
        test_run_date: '11.11.2000',
        request_file_id: request_file_id
    }
    expect { post '/api/results_with_data_id', params }.to change { Result.count }.by(1)
    expect(response.status).to eq(200)
    expect(json_response_body).to match('result_id' => 1, 'status' => 'created')
  end

  it 'upload request and perfmon files and create result' do
    post '/request_file', :file => Rack::Test::UploadedFile.new(summary_file_path, 'text/csv')
    post '/performance_file', :file => Rack::Test::UploadedFile.new(perfmon_file_path, 'text/csv')
    request_file_id = JSON.parse(response.body)['id']
    project = create(:project)
    params = {
        project: project.project_name,
        version: 'version3',
        duration: '123',
        rps: '123',
        profile: '123',
        test_run_date: '11.11.2000',
        request_file_id: request_file_id
    }
    expect { post '/api/results_with_data_id', params }.to change { Result.count }.by(1)
    expect(response.status).to eq(200)
    expect(json_response_body).to match('result_id' => 1, 'status' => 'created')
  end
end
