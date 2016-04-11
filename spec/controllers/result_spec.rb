require 'rails_helper'

describe ResultsController do
  let(:summary_file) { File.read File.join(fixture_path, 'summary.csv') }
  let(:perfmon_file) { File.read File.join(fixture_path, 'perfmon.csv') }
  let(:summary_base64) { Base64.encode64(summary_file) }
  let(:summary_file_name) { File.basename(summary_file) }
  let(:perfmon_base64) { Base64.encode64(perfmon_file) }
  let(:perfmon_file_name) { File.basename(perfmon_file) }

  before { DatabaseCleaner.clean }

  it 'POST with correct parameters and summary' do
    params = {
      version: 'version3',
      duration: '123',
      rps: '123',
      profile: '123',
      test_run_date: '11.11.2000',
      requests_data: { file: summary_base64, filename: summary_file_name }
    }
    @request.env['CONTENT_TYPE'] = 'application/json'
    post 'create', params
    expect(json_response_body).to match('result_id' => 1, 'status' => 'created')
  end

  it 'POST with correct parameters and summary plus performance' do
    params = {
      version: 'version3',
      duration: '123',
      rps: '123',
      profile: '123',
      test_run_date: '11.11.2000',
      requests_data: { file: summary_base64, filename: summary_file_name },
      perfmon_data: { file: perfmon_base64, filename: perfmon_file_name }
    }
    @request.env['CONTENT_TYPE'] = 'application/json'
    post 'create', params
    expect(json_response_body).to match('result_id' => 1, 'status' => 'created')
  end

  it 'POST with correct parameters with time cutting and summary plus performance' do
    params = {
      version: 'version3',
      duration: '123',
      rps: '123',
      profile: '123',
      test_run_date: '11.11.2000',
      time_cutting_percent: '1',
      requests_data: { file: summary_base64, filename: summary_file_name },
      perfmon_data: { file: perfmon_base64, filename: perfmon_file_name }
    }
    @request.env['CONTENT_TYPE'] = 'application/json'
    post 'create', params
    expect(json_response_body).to match('result_id' => 1, 'status' => 'created')
  end

  it 'POST with correct parameters but without summary' do
    params = {
      version: 'version3',
      duration: '123',
      rps: '123',
      profile: '123',
      test_run_date: '11.11.2000'
    }
    @request.env['CONTENT_TYPE'] = 'application/json'
    post 'create', params
    expect(json_response_body).to eq(['Request data is required'])
  end

  it 'POST with absent parameter' do
    params = {
      version: 'version3',
      duration: '123',
      rps: '123',
      test_run_date: '11.11.2000',
      requests_data: { file: summary_base64, filename: summary_file_name }
    }
    @request.env['CONTENT_TYPE'] = 'application/json'
    post 'create', params
    expect(json_response_body).to eq(["Profile can't be blank"])
  end
end
