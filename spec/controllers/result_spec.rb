require 'rails_helper'

describe ResultsController do
  summary_base64 = Base64.encode64(File.read(File.join(fixture_path, 'summary.csv')))
  summary_file_name = File.basename(File.join(fixture_path, 'summary.csv'))
  perfmon_base64 = Base64.encode64(File.read(File.join(fixture_path, 'perfmon.csv')))
  perfmon_file_name = File.basename(File.join(fixture_path, 'perfmon.csv'))

  it 'POST with correct parameters and summary' do
    params =
        {version: 'version3',
         duration: '123',
         rps: '123',
         profile: '123',
         test_run_date: '11.11.2000',
         requests_data: {file: summary_base64, filename: summary_file_name}
        }
    @request.env['CONTENT_TYPE'] = 'application/json'
    post 'create', params
    expect(response.body.gsub(/["{}]/, '')).to match(/result_id:\d+,status:created/)
  end

  it 'POST with correct parameters and summary plus performance' do
    params =
        {version: 'version3',
         duration: '123',
         rps: '123',
         profile: '123',
         test_run_date: '11.11.2000',
         requests_data: {file: summary_base64, filename: summary_file_name},
         perfmon_data: {file: perfmon_base64, filename: perfmon_file_name}
        }
    @request.env['CONTENT_TYPE'] = 'application/json'
    post 'create', params
    expect(response.body.gsub(/["{}]/, '')).to match(/result_id:\d+,status:created/)
  end

  it 'POST with correct parameters with time cutting and summary plus performance' do
    params =
        {version: 'version3',
         duration: '123',
         rps: '123',
         profile: '123',
         test_run_date: '11.11.2000',
         time_cutting_percent: '1',
         requests_data: {file: summary_base64, filename: summary_file_name},
         perfmon_data: {file: perfmon_base64, filename: perfmon_file_name}
        }
    @request.env['CONTENT_TYPE'] = 'application/json'
    post 'create', params
    expect(response.body.gsub(/["{}]/, '')).to match(/result_id:\d+,status:created/)
  end

  it 'POST with correct parameters but without summary' do
    params =
        {version: 'version3',
         duration: '123',
         rps: '123',
         profile: '123',
         test_run_date: '11.11.2000'}
    @request.env['CONTENT_TYPE'] = 'application/json'
    post 'create', params
    expect(response.body.gsub(/"/, '')).to match(/.Request data is required./)
  end

  it 'POST with absent parameter' do
    params =
        {version: 'version3',
         duration: '123',
         rps: '123',
         test_run_date: '11.11.2000',
         requests_data: {file: summary_base64, filename: summary_file_name},}
    @request.env['CONTENT_TYPE'] = 'application/json'
    post 'create', params
    expect(response.body.gsub(/"/, '')).to match(/.Profile can't be blank./)
  end
end