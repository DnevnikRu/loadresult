require 'rails_helper'

describe 'Results API', type: :request do
  let(:summary_file) {File.read File.join(fixture_path, 'summary.csv')}
  let(:perfmon_file) {File.read File.join(fixture_path, 'perfmon.csv')}
  let(:summary_base64) {Base64.encode64(summary_file)}
  let(:summary_file_name) {File.basename(summary_file)}
  let(:perfmon_base64) {Base64.encode64(perfmon_file)}
  let(:perfmon_file_name) {File.basename(perfmon_file)}

  before do
    DatabaseCleaner.clean
    @project = create(:project, project_name: 'Dnevnik')
  end

  it 'creates a result if correct parameters and summary' do
    params = {
        project: 'Dnevnik',
        version: 'version3',
        duration: '123',
        rps: '123',
        profile: '123',
        test_run_date: '11.11.2000',
        requests_data: {file: summary_base64, filename: summary_file_name}
    }
    expect {post '/api/results', params}.to change {Result.count}.by(1)
    # post '/api/results', params
    # binding.pry
    expect(response.status).to eq(200)
    expect(json_response_body).to match('result_id' => 1, 'status' => 'created')
  end

  it 'creates a result if correct parameters and summary plus performance' do
    params = {
        project: 'Dnevnik',
        version: 'version3',
        duration: '123',
        rps: '123',
        profile: '123',
        test_run_date: '11.11.2000',
        requests_data: {file: summary_base64, filename: summary_file_name},
        perfmon_data: {file: perfmon_base64, filename: perfmon_file_name}
    }
    expect {post '/api/results', params}.to change {Result.count}.by(1)
    expect(response.status).to eq(200)
    expect(json_response_body).to match('result_id' => 1, 'status' => 'created')
  end

  it 'creates a result if correct parameters with time cutting and summary plus performance' do
    params = {
        project: 'Dnevnik',
        version: 'version3',
        duration: '123',
        rps: '123',
        profile: '123',
        test_run_date: '11.11.2000',
        time_cutting_percent: '1',
        requests_data: {file: summary_base64, filename: summary_file_name},
        perfmon_data: {file: perfmon_base64, filename: perfmon_file_name}
    }
    expect {post '/api/results', params}.to change {Result.count}.by(1)
    expect(response.status).to eq(200)
    expect(json_response_body).to match('result_id' => 1, 'status' => 'created')
  end

  it 'does not create a result if correct parameters but without summary' do
    params = {
        project: 'Dnevnik',
        version: 'version3',
        duration: '123',
        rps: '123',
        profile: '123',
        test_run_date: '11.11.2000'
    }
    expect {post '/api/results', params}.to_not change {Result.count}
    expect(response.status).to eq(400)
    expect(json_response_body).to eq(['Request data is required'])
  end

  it 'does not create a result with wrong project' do
    params = {
        project: 'Dnvnik',
        version: 'version3',
        duration: '123',
        rps: '123',
        profile: '123',
        test_run_date: '11.11.2000',
        requests_data: {file: summary_base64, filename: summary_file_name}
    }
    expect {post '/api/results', params}.to_not change {Result.count}
    expect(response.status).to eq(400)
    expect(json_response_body).to eq(["Project can't be blank"])
  end

  it 'does not create a result if project is empty' do
    params = {
        project: nil,
        version: 'version3',
        duration: '123',
        rps: '123',
        profile: '123',
        test_run_date: '11.11.2000',
        requests_data: {file: summary_base64, filename: summary_file_name}
    }
    expect {post '/api/results', params}.to_not change {Result.count}
    expect(response.status).to eq(400)
    expect(json_response_body).to eq(["Project can't be blank"])
  end

  it 'does not create a result if profile is absent' do
    params = {
        project: 'Dnevnik',
        version: 'version3',
        duration: '123',
        rps: '123',
        test_run_date: '11.11.2000',
        requests_data: {file: summary_base64, filename: summary_file_name}
    }
    expect {post '/api/results', params}.to_not change {Result.count}
    expect(response.status).to eq(400)
    expect(json_response_body).to eq(["Profile can't be blank"])
  end


end

describe 'Get results with filters', type: :request do
  before(:all) do
    DatabaseCleaner.clean
    @project = create(:project, project_name: 'test_api_result_filters')
    @expected_results = [
        create(:result, project_id: @project.id, version: '4.1.0'),
        create(:result, project_id: @project.id, version: '4.1.1'),
        create(:result, project_id: @project.id, version: '4.1.2'),
        create(:result, project_id: @project.id, version: '4.1.11'),
        create(:result, project_id: @project.id, version: '4.1.11-load-test'),
        create(:result, project_id: @project.id, version: 'load-test'),
        create(:result, project_id: @project.id, version: '4.1.11', rps: 1000),
        create(:result, project_id: @project.id, version: '4.1.11', profile: 'test'),
        create(:result, project_id: @project.id, version: '4.1.11', duration: 800)
    ]
  end

  it 'filter by project' do
    get('/api/results', project: @project.project_name)
    results = json_response_body
    expect(response.status).to eq(200)
    expect(results).to_not be_empty
    expect(results.count).to eql(@expected_results.count)
  end

  it 'filter by project and rps' do
    get('/api/results', project: @project.project_name, rps: 1000)
    results = json_response_body
    expect(response.status).to eq(200)
    expect(results).to_not be_empty
    expect(results.count).to eql(1)
  end

  it 'filter by project and profile' do
    get('/api/results', project: @project.project_name, profile: 'test')
    results = json_response_body
    expect(response.status).to eq(200)
    expect(results).to_not be_empty
    expect(results.count).to eql(1)
  end

  it 'filter by project and duration' do
    get('/api/results', project: @project.project_name, duration: 800)
    results = json_response_body
    expect(response.status).to eq(200)
    expect(results).to_not be_empty
    expect(results.count).to eql(1)
  end

  it 'sort by version' do
    get('/api/results', project: @project.project_name, sort_by: 'version')
    results = json_response_body
    expect(response.status).to eq(200)
    expect(results).to_not be_empty
    expect(results.first['version']).to eql('4.1.11')
  end

  it 'filter with limit' do
    get('/api/results', project: @project.project_name, limit: 2)
    results = json_response_body
    expect(response.status).to eq(200)
    expect(results).to_not be_empty
    expect(results.count).to eql(2)
  end
end
