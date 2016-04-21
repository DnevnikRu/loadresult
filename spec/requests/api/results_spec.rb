require 'rails_helper'

describe 'Results API', type: :request do
  let(:summary_file) { File.read File.join(fixture_path, 'summary.csv') }
  let(:perfmon_file) { File.read File.join(fixture_path, 'perfmon.csv') }
  let(:summary_base64) { Base64.encode64(summary_file) }
  let(:summary_file_name) { File.basename(summary_file) }
  let(:perfmon_base64) { Base64.encode64(perfmon_file) }
  let(:perfmon_file_name) { File.basename(perfmon_file) }

  before { DatabaseCleaner.clean }

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
    expect { post '/api/results', params }.to change { Result.count }.by(1)
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
    expect { post '/api/results', params }.to change { Result.count }.by(1)
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
    expect { post '/api/results', params }.to change { Result.count }.by(1)
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
    expect { post '/api/results', params }.to_not change { Result.count }
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
    expect { post '/api/results', params }.to_not change { Result.count }
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
    expect { post '/api/results', params }.to_not change { Result.count }
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
    expect { post '/api/results', params }.to_not change { Result.count }
    expect(response.status).to eq(400)
    expect(json_response_body).to eq(["Profile can't be blank"])
  end
end
