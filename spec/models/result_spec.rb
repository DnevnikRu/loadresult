require 'rails_helper'

describe Result do
  it 'has a valid factory' do
    expect(build(:result)).to be_valid
  end

  it 'invalid without version' do
    expect(build(:result, :version => nil)).not_to be_valid
  end

  it 'invalid without duration' do
    expect(build(:result, :duration => nil)).not_to be_valid
  end

  it 'invalid without rps' do
    expect(build(:result, :rps => nil)).not_to be_valid
  end

  it 'invalid without profile' do
    expect(build(:result, :profile => nil)).not_to be_valid
  end

  it 'invalid with test_run_date in wrong format' do
    expect(build(:result, :test_run_date => 'das')).not_to be_valid
  end

  it 'invalid without project id' do
    expect(build(:result, :project_id => nil)).not_to be_valid
  end

  it 'do not create not valid object' do
    expect { create(:result, :test_run_date => 'das') }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'has many requests_result' do
    result = create(:result)
    create(:requests_result, result_id: result.id)
    create(:requests_result, result_id: result.id)
    expect(result.requests_results.count).to eql(2)
  end

  describe '.upload_and_create' do
    before(:all) do
      @summary = Tempfile.new('requests_data_temp')
      @perfmon = Tempfile.new('perfmon_data_temp')
      File.open(File.join(fixture_path, 'summary.csv'), 'r') do |f|
        @summary.write f.read
      end
      File.open(File.join(fixture_path, 'perfmon.csv'), 'r') do |f|
        @perfmon.write f.read
      end
      @summary.close
      @perfmon.close
    end

    describe 'all parameters are presence and valid' do
      before(:all) do
        @summary.open
        @perfmon.open
        performance_data = ActionDispatch::Http::UploadedFile.new(tempfile: @perfmon, filename: 'perfmon.csv')
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary, filename: 'summary.csv')
        params = {
            'project' => 1,
            'version' => 'edu',
            'rps' => 150,
            'duration' => 123,
            'profile' => 'asd',
            'test_run_date' => '2016-02-11 11:21',
            'release_date' => '2016-02-11 11:21',
            'requests_data' => requests_data,
            'performance_data' => performance_data
        }

        @result = Result.upload_and_create(params)
        @summary.close
        @perfmon.close
      end

      it 'empty errors' do
        expect(@result.errors).to be_empty
      end

      it 'result saved' do
        expect(Result.find_by(id: @result.id)).not_to be_nil
      end

      it 'request data save' do
        expect(@result.requests_results.count).to eql(9)
      end

      it 'perfmon data save' do
        expect(@result.performance_results.count).to eql(8)
      end

      it 'calculated request results save' do
        expect(CalculatedRequestsResult.find_by result_id: @result.id).not_to be_nil
      end

      it 'calculated performance results save' do
        expect(CalculatedPerformanceResult.find_by result_id: @result.id).not_to be_nil
      end

      it 'requests data file name saved in database' do
        expect(@result.requests_data_identifier).to eql 'summary.csv'
      end

      it 'performance data file name saved in database' do
        expect(@result.performance_data_identifier).to eql 'perfmon.csv'
      end

    end

    describe 'some parameters absence' do
      describe 'perfmon data is absence' do
        before(:all) do
          @summary.open
          requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary, filename: 'summary.csv')
          params = {
              'project' => 1,
              'version' => 'edu',
              'rps' => 150,
              'duration' => 123,
              'profile' => 'asd',
              'test_run_date' => '2016-02-11 11:21',
              'requests_data' => requests_data
          }
          @result = Result.upload_and_create(params)
          @summary.close
        end
        it 'empty errors without perfmon data' do
          expect(@result.errors).to be_empty
        end

        it 'calculated request results save without perfmon data' do
          expect(CalculatedRequestsResult.find_by result_id: @result.id).not_to be_nil
        end

        it 'calculated performance results not save without perfmon data' do
          expect(CalculatedPerformanceResult.find_by result_id: @result.id).to be nil
        end
      end

      it 'release_date is absent' do
        @summary.open
        @perfmon.open
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary, filename: 'summary.csv')
        performance_data = ActionDispatch::Http::UploadedFile.new(tempfile: @perfmon, filename: 'perfmon.csv')
        params = {
            'project' => 1,
            'version' => 'edu',
            'rps' => 150,
            'duration' => 123,
            'profile' => 'asd',
            'test_run_date' => '2016-02-11 11:21',
            'requests_data' => requests_data,
            'performance_data' => performance_data
        }
        @result = Result.upload_and_create(params)
        @summary.close
        @perfmon.close
        expect(@result.errors).to be_empty
      end

      describe 'version is absence, other required fields presence' do
        before(:all) do
          @summary.open
          @perfmon.open
          performance_data = ActionDispatch::Http::UploadedFile.new(tempfile: @perfmon, filename: 'perfmon.csv')
          requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary, filename: 'summary.csv')
          params = {
              'project' => 1,
              'rps' => 150,
              'duration' => 123,
              'profile' => 'asd',
              'test_run_date' => '2016-02-11 11:21',
              'requests_data' => requests_data,
              'performance_data' => performance_data
          }
          @result = Result.upload_and_create(params)
          @summary.close
          @perfmon.close
        end
        it 'errors present without version' do
          expect(@result.errors).to match_array(["Version can't be blank"])
        end

        it 'calculated request results not save without version' do
          expect(CalculatedRequestsResult.find_by result_id: @result.id).to be nil
        end

        it 'calculated performance results not save without version' do
          expect(CalculatedPerformanceResult.find_by result_id: @result.id).to be nil
        end
      end

      describe 'project is absence, other required fields presence' do
        before(:all) do
          @summary.open
          @perfmon.open
          performance_data = ActionDispatch::Http::UploadedFile.new(tempfile: @perfmon, filename: 'perfmon.csv')
          requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary, filename: 'summary.csv')
          params = {
              'version' => 'edu',
              'rps' => 150,
              'duration' => 123,
              'profile' => 'asd',
              'test_run_date' => '2016-02-11 11:21',
              'requests_data' => requests_data,
              'performance_data' => performance_data
          }
          @result = Result.upload_and_create(params)
          @summary.close
          @perfmon.close
        end
        it 'errors present without project' do
          expect(@result.errors).to match_array(["Project can't be blank"])
        end

        it 'calculated request results not save without version' do
          expect(CalculatedRequestsResult.find_by result_id: @result.id).to be nil
        end

        it 'calculated performance results not save without version' do
          expect(CalculatedPerformanceResult.find_by result_id: @result.id).to be nil
        end
      end

      it 'rps is absence, other required fields presence' do
        @summary.open
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary, filename: 'summary.csv')
        params = {
            'project' => 1,
            'version' => 'asd',
            'duration' => 123,
            'profile' => 'asd',
            'test_run_date' => '2016-02-11 11:21',
            'requests_data' => requests_data
        }
        result = Result.upload_and_create(params)
        expect(result.errors).to match_array(["Rps can't be blank"])
        @summary.close
      end

      it 'duration is absence, other required fields presence' do
        @summary.open
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary, filename: 'summary.csv')
        params = {
            'project' => 1,
            'version' => 'asd',
            'rps' => 150,
            'profile' => 'asd',
            'test_run_date' => '2016-02-11 11:21',
            'requests_data' => requests_data
        }
        result = Result.upload_and_create(params)
        expect(result.errors).to match_array(["Duration can't be blank"])
        @summary.close
      end

      it 'profile is absence, other required fields presence' do
        @summary.open
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary, filename: 'summary.csv')
        params = {
            'project' => 1,
            'version' => 'asd',
            'duration' => 123,
            'rps' => 150,
            'test_run_date' => '2016-02-11 11:21',
            'requests_data' => requests_data
        }
        result = Result.upload_and_create(params)
        expect(result.errors).to match_array(["Profile can't be blank"])
        @summary.close
      end


      it 'date is absence, other required fields presence' do
        @summary.open
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary, filename: 'summary.csv')
        params = {
            'project' => 1,
            'version' => 'asd',
            'duration' => 123,
            'rps' => 150,
            'profile' => 'asd',
            'requests_data' => requests_data,
            'test_run_date' => ''
        }
        result = Result.upload_and_create(params)
        expect(result.errors).to match_array(['Test run date must be in a datetime format'])
        @summary.close
      end

      it 'request data is absence, other required fields presence' do
        params = {
            'project' => 1,
            'version' => 'asd',
            'duration' => 123,
            'rps' => 150,
            'profile' => 'asd',
            'test_run_date' => '2016-02-11 11:21'
        }
        result = Result.upload_and_create(params)
        expect(result.errors).to match_array(['Request data is required'])
        @summary.close
      end

      it 'release_date presence but not date' do
        @summary.open
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary, filename: 'summary.csv')
        params = {
            'project' => 1,
            'version' => 'asd',
            'duration' => 123,
            'rps' => 150,
            'profile' => 'asd',
            'test_run_date' => '2016-02-11 11:21',
            'release_date' => 'agsdgdfg',
            'requests_data' => requests_data,
        }
        result = Result.upload_and_create(params)
        expect(result.errors).to match_array(['Release date must be a valid datetime'])
        @summary.close
      end
    end

    describe 'absence required columns in request and perfmon data' do
      before(:all) do
        @invalid_summary = Tempfile.new('requests_data_temp')
        @invalid_perfmon = Tempfile.new('perfmon_data_temp')

        File.open(File.join(fixture_path, 'summary_invalid_header.csv'), 'r') do |f|
          @invalid_summary.write f.read
        end
        File.open(File.join(fixture_path, 'perfmon_invalid_header.csv'), 'r') do |f|
          @invalid_perfmon.write f.read
        end
        @invalid_summary.close
        @invalid_perfmon.close
      end


      describe 'absence required columns in request data' do

        before(:all) do
          @invalid_summary.open
          requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @invalid_summary, filename: 'summary_invalid_header.csv')
          params = {
              'project' => 1,
              'version' => 'edu',
              'rps' => 150,
              'duration' => 123,
              'profile' => 'asd',
              'test_run_date' => '2016-02-11 11:21',
              'requests_data' => requests_data
          }

          @result = Result.upload_and_create(params)
          @invalid_summary.close
        end

        it 'result include correct errors' do
          errors = []
          required_column = %w(timeStamp label responseCode Latency)
          required_column.each do |column|
            errors.push "#{column} column in request data is required!"
          end
          expect(@result.errors).to match_array(errors)
        end

        it 'result does not save' do
          expect(Result.find_by(id: @result.id)).to be_nil
        end

        it 'requests data not save' do
          expect(RequestsResult.where(result_id: @result.id).empty?).to be(true)
        end

        it 'calculated request results not save' do
          expect(CalculatedRequestsResult.find_by result_id: @result.id).to be nil
        end

        it 'calculated performance results not save' do
          expect(CalculatedPerformanceResult.find_by result_id: @result.id).to be nil
        end

      end

      describe 'absence required columns in perfmon data' do
        before(:all) do
          @summary.open
          @invalid_perfmon.open
          perfmon_data = ActionDispatch::Http::UploadedFile.new(tempfile: @invalid_perfmon, filename: 'perfmon_invalid_header.csv')
          requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary, filename: 'summary.csv')
          params = {
              'project' => 1,
              'version' => 'edu',
              'rps' => 150,
              'duration' => 123,
              'profile' => 'asd',
              'test_run_date' => '2016-02-11 11:21',
              'requests_data' => requests_data,
              'performance_data' => perfmon_data
          }

          @result = Result.upload_and_create(params)
          @summary.close
          @invalid_perfmon.close
        end

        it 'result include correct errors' do
          errors = []
          required_column = %w(timeStamp label elapsed)
          required_column.each do |column|
            errors.push "#{column} column in performance data is required!"
          end
          expect(@result.errors).to match_array(errors)
        end

        it 'result does not save' do
          expect(Result.find_by(id: @result.id)).to be_nil
        end

        it 'perfmon data not save' do
          expect(PerformanceResult.where(result_id: @result.id).empty?).to be(true)
        end

        it 'calculated request results not save' do
          expect(CalculatedRequestsResult.find_by result_id: @result.id).to be nil
        end

        it 'calculated performance results not save' do
          expect(CalculatedPerformanceResult.find_by result_id: @result.id).to be nil
        end

      end
    end
  end

  describe '.calc_request_data' do
    describe 'timestamps and request calculate with nonexistent label' do

      before(:all) do
        @result = create(:result, time_cutting_percent: 10)
        create(:requests_result, result_id: @result.id, timestamp: 1455023039548)
        create(:requests_result, result_id: @result.id, timestamp: 1455023040000)
        create(:requests_result, result_id: @result.id, timestamp: 1455023045000)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050000)
        create(:requests_result, result_id: @result.id, timestamp: 1455023055000)
        create(:requests_result, result_id: @result.id, timestamp: 1455023060000)
        Result.calc_request_data(@result)
        @calculated_results = @result.calculated_requests_results
      end

      it 'timestamp borders are correct' do
        borders = Result.border_timestamps(@result.id, RequestsResult, 10)
        expect(borders).to match_array([1455023041593, 1455023057955])
      end

      it 'request calculated results is nill with wrong label' do
        expect(@calculated_results.find_by(label: 'root /invites.aspx:GET')).to eql nil
      end

    end

    describe 'request calculate with standard values' do

      before(:all) do
        @result = create(:result, time_cutting_percent: 10)
        @label = 'children /marks.aspx:GET:tab=subject'
        create(:requests_result, result_id: @result.id, timestamp: 1455023040000, value: 123, response_code: 600, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023045000, value: 1400, response_code: 500, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050500, value: 1, response_code: 499, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 346, response_code: 400, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 345, response_code: 599, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 344, response_code: 399, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 343, response_code: 501, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 342, response_code: 401, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 341, response_code: 200, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 348, response_code: 100, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 1238, response_code: 123, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023060000, value: 123, response_code: 9880, label: @label)
        Result.calc_request_data(@result)
        @calculated_results = @result.calculated_requests_results

      end

      it 'request mean is correct with standard values' do
        expect(@calculated_results.find_by(label: @label).mean).to eql 504.8
      end
      it 'request median is correct with standard values' do
        expect(@calculated_results.find_by(label: @label).median).to eql 344.5
      end
      it 'request 90 percent is correct with standard values' do
        expect(@calculated_results.find_by(label: @label).ninety_percentile).to eql 1238.0
      end
      it 'request max is correct with standard values' do
        expect(@calculated_results.find_by(label: @label).max).to eql 1400.0
      end
      it 'request min is correct with standard values' do
        expect(@calculated_results.find_by(label: @label).min).to eql 1.0
      end
      it 'failed tests percentage is correct with standard values' do
        expect(@calculated_results.find_by(label: @label).failed_results).to eql 60.0
      end
    end

    describe 'request calculate with different values' do

      before(:all) do
        @result = create(:result)
        @label = 'children /marks.aspx:GET:tab=subject'
        create(:requests_result, result_id: @result.id, timestamp: 1455023040000, value: 123, response_code: 600, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023045000, value: 0, response_code: 500, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050500, value: 0.1, response_code: 499, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 346, response_code: nil, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 345, response_code: 599, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 344, response_code: 'Non HTTP response code: org.apache.http.ConnectionClosedException', label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 343, response_code: 1, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023060000, value: 123, response_code: 9880, label: @label)
        Result.calc_request_data(@result)
        @calculated_results = @result.calculated_requests_results
      end

      it 'request mean is correct with different values' do
        expect(@calculated_results.find_by(label: @label).mean).to eql 229.67
      end
      it 'request median is correct with different values' do
        expect(@calculated_results.find_by(label: @label).median).to eql 343.5
      end
      it 'request 90 percent is correct with different values' do
        expect(@calculated_results.find_by(label: @label).ninety_percentile).to eql 345.5
      end
      it 'request max is correct with different values' do
        expect(@calculated_results.find_by(label: @label).max).to eql 346.0
      end
      it 'request min is correct with different values' do
        expect(@calculated_results.find_by(label: @label).min).to eql 0.0
      end
      it 'failed tests percentage is correct with different values' do
        expect(@calculated_results.find_by(label: @label).failed_results).to eql 83.33
      end
    end

    describe 'request calculate with same values' do

      before(:all) do
        @result = create(:result)
        @label = 'children /marks.aspx:GET:tab=subject'
        create(:requests_result, result_id: @result.id, timestamp: 1455023040000, value: 123, response_code: 123, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023045000, value: 123, response_code: 123, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023047500, value: 123, response_code: 123, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050500, value: 123, response_code: 123, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 123, response_code: 123, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050601, value: 123, response_code: 123, label: @label)
        Result.calc_request_data(@result)
        @calculated_results = @result.calculated_requests_results
      end

      it 'request mean is correct with same values' do
        expect(@calculated_results.find_by(label: @label).mean).to eql 123.0
      end
      it 'request median is correct with same values' do
        expect(@calculated_results.find_by(label: @label).median).to eql 123.0
      end
      it 'request 90 percent is correct with same values' do
        expect(@calculated_results.find_by(label: @label).ninety_percentile).to eql 123.0
      end
      it 'request max is correct with same values' do
        expect(@calculated_results.find_by(label: @label).max).to eql 123.0
      end
      it 'request min is correct with same values' do
        expect(@calculated_results.find_by(label: @label).min).to eql 123.0
      end
      it 'failed tests percentage is correct with same values' do
        expect(@calculated_results.find_by(label: @label).failed_results).to eql 0.0
      end
    end

    describe 'request throughput with different timestamps' do

      before(:all) do
        @result = create(:result)
        @label = 'children /marks.aspx:GET:tab=subject'
        create(:requests_result, result_id: @result.id, timestamp: 1455023040000, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023040600, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023040700, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023040800, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023040900, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023041000, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023041100, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023041200, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023041300, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023041400, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023041500, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023041600, label: @label)
        Result.calc_request_data(@result)
        @calculated_results = @result.calculated_requests_results
      end

      it 'request throughput with different timestamps' do
        expect(@calculated_results.find_by(label: @label).throughput).to eql 7.03
      end
    end

    describe 'request throughput with same timestamps' do

      before(:all) do
        @result = create(:result)
        @label = 'children /marks.aspx:GET:tab=subject'
        create(:requests_result, result_id: @result.id, timestamp: 1455023040500, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023040600, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023040600, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023040600, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023040600, label: @label)
        create(:requests_result, result_id: @result.id, timestamp: 1455023040700, label: @label)
        Result.calc_request_data(@result)
        @calculated_results = @result.calculated_requests_results
      end

      it 'request throughput with same timestamps' do
        expect(@calculated_results.find_by(label: @label).throughput).to eql 4.0
      end
    end
  end

  describe '.calc_performance_data' do
    describe 'perfomance calculate with correct values and with not existent label' do

      before(:all) do
        @result = create(:result)
        @label = 'EXEC Network\Bytes Sent/sec'
        create(:performance_result, result_id: @result.id, timestamp: 1455023039548, value: 2, label: @label)
        create(:performance_result, result_id: @result.id, timestamp: 1455023040000, value: 123, label: @label)
        create(:performance_result, result_id: @result.id, timestamp: 1455023045000, value: 121, label: @label)
        create(:performance_result, result_id: @result.id, timestamp: 1455023050000, value: 1000, label: @label)
        create(:performance_result, result_id: @result.id, timestamp: 1455023055000, value: 12, label: @label)
        create(:performance_result, result_id: @result.id, timestamp: 1455023060000, value: 6, label: @label)
        Result.calc_performance_data(@result)
        @calculated_results = @result.calculated_performance_results
      end

      it 'performance mean is correct' do
        expect(@calculated_results.find_by(label: @label).mean).to eql 377.67
      end

      it 'performance minimum is correct' do
        expect(@calculated_results.find_by(label: @label).min).to eql 12.0
      end

      it 'performance maximum is correct' do
        expect(@calculated_results.find_by(label: @label).max).to eql 1000.0
      end
      it 'performance results is nill with nonexistent label' do
        expect(@calculated_results.find_by(label: 'EXEC Events\Bytes Sent/sec')).to eql nil
      end

    end
  end

  describe 'destroying result' do
    before do
      @result = create(:result)
      create(:performance_result, result_id: @result.id)
      create(:calculated_performance_result, result_id: @result.id)
      create(:requests_result, result_id: @result.id)
      create(:calculated_requests_result, result_id: @result.id)
    end

    it 'destroys Result itself' do
      expect { @result.destroy }.to change { Result.count }.by(-1)
    end

    it 'destroys CalculatedRequestsResult' do
      expect { @result.destroy }.to change { CalculatedRequestsResult.count }.by(-1)
    end

    it 'destroys CalculatedPerformanceResult' do
      expect { @result.destroy }.to change { CalculatedPerformanceResult.count }.by(-1)
    end

    it 'does not destroy RequestsResult' do
      expect { @result.destroy }.to change { RequestsResult.count }.by(-1)
    end

    it 'does not destroy PerformanceResult' do
      expect { @result.destroy }.to change { PerformanceResult.count }.by(-1)
    end
  end

  describe '.values_of_requests' do
    before do
      @result = create(:result)
      (1..10).each do |i|
        create(
            :requests_result,
            result_id: @result.id,
            timestamp: i * 10,
            value: i,
            label: 'first label'
        )
      end
      (11..20).each do |i|
        create(
            :requests_result,
            result_id: @result.id,
            timestamp: i * 10,
            value: i,
            label: 'second label'
        )
      end
    end

    it 'returns an Array' do
      expect(Result.values_of_requests(@result.id, 10)).to be_an(Array)
    end

    it 'returns values for result id' do
      expect(Result.values_of_requests(@result.id, 10)).to eq([3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18])
    end

    it 'returns values for result id and label' do
      expect(Result.values_of_requests(@result.id, 'first label', 10)).to eq([2, 3, 4, 5, 6, 7, 8, 9])
    end
  end

  describe '.percentile_of_values_of_requests' do
    before do
      @result = create(:result)
      (1..10).each do |i|
        create(
            :requests_result,
            result_id: @result.id,
            timestamp: i * 10,
            value: i
        )
      end
    end

    it 'returns an Array' do
      expect(Result.percentile_of_values_of_requests(@result.id, @result.time_cutting_percent)).to be_an(Array)
    end

    it 'finds percentile for each percent' do
      expect(Result.percentile_of_values_of_requests(@result.id, @result.time_cutting_percent).size).to eq(100)
    end
  end

  describe '.performance_seconds_to_values' do
    before do
      @result = create(:result)
      (0..10).each do |i|
        create(
            :performance_result,
            result_id: @result.id,
            timestamp: i * 1000,
            value: i,
            label: 'cpu_1'
        )
        create(
            :performance_result,
            result_id: @result.id,
            timestamp: i * 1000,
            value: i * 2,
            label: 'cpu_2'
        )
      end
    end

    it 'returns a Hash' do
      expect(Result.performance_seconds_to_values(@result.id, ['cpu_1', 'cpu_2'], 10)).to be_a(Hash)
    end

    it 'calculates seconds' do
      perf_sec_to_values = Result.performance_seconds_to_values(@result.id, ['cpu_1', 'cpu_2'], 10)
      expect(perf_sec_to_values['cpu_1'][:seconds]).to eq([0, 1, 2, 3, 4, 5, 6, 7, 8])
    end

    it 'cut sent percent from values' do
      perf_sec_to_values = Result.performance_seconds_to_values(@result.id, ['cpu_1', 'cpu_2'], 10)
      expect(perf_sec_to_values['cpu_1'][:values]).to eq([1, 2, 3, 4, 5, 6, 7, 8, 9])
    end

    it 'handle all labels' do
      perf_sec_to_values = Result.performance_seconds_to_values(@result.id, ['cpu_1', 'cpu_2'], 10)
      expect(perf_sec_to_values).to have_key('cpu_1')
      expect(perf_sec_to_values).to have_key('cpu_2')
    end
  end

  describe '.requests_seconds_to_values' do
    before do
      @result = create(:result)
      (0..10).each do |i|
        create(
            :requests_result,
            result_id: @result.id,
            timestamp: i * 1000,
            value: i,
            label: 'login :GET'
        )
      end
    end

    it 'returns a Hash' do
      expect(Result.requests_seconds_to_values(@result.id, 'login :GET', 10)).to be_a(Hash)
    end

    it 'calculates seconds' do
      req_sec_to_values = Result.requests_seconds_to_values(@result.id, 'login :GET', 10)
      expect(req_sec_to_values[:seconds]).to eq([0, 1, 2, 3, 4, 5, 6, 7, 8])
    end

    it 'cut sent percent from values' do
      req_sec_to_values = Result.requests_seconds_to_values(@result.id, 'login :GET', 10)
      expect(req_sec_to_values[:values]).to eq([1, 2, 3, 4, 5, 6, 7, 8, 9])
    end
  end

  describe '.border_timestamps' do
    before do
      @result = create(:result)
      (0..10).each do |i|
        create(
            :performance_result,
            result_id: @result.id,
            timestamp: i
        )
      end
    end

    it 'returns an Array' do
      expect(Result.border_timestamps(@result.id, PerformanceResult, 10)).to be_an(Array)
    end

    it 'returns the minimum and maximum timestamp after cutting 0 percent' do
      expect(Result.border_timestamps(@result.id, PerformanceResult, 0)).to eq([0, 10])
    end

    it 'returns the minimum and maximum timestamp after cutting 10 percent' do
      expect(Result.border_timestamps(@result.id, PerformanceResult, 10)).to eq([1, 9])
    end

    it 'returns the minimum and maximum timestamp after cutting 20 percent' do
      expect(Result.border_timestamps(@result.id, PerformanceResult, 20)).to eq([2, 8])
    end
  end

  describe '.update_and_recalculate' do

    describe 'Update and recalculate only with request data' do
      before(:all) do
        @result = create(:result, time_cutting_percent: 10)
        create(:requests_result, result_id: @result.id, timestamp: 1455023039548, value: 2)
        create(:requests_result, result_id: @result.id, timestamp: 1455023040000, value: 123)
        create(:requests_result, result_id: @result.id, timestamp: 1455023045000, value: 121)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050000, value: 1000)
        create(:requests_result, result_id: @result.id, timestamp: 1455023055000, value: 12)
        create(:requests_result, result_id: @result.id, timestamp: 1455023060000, value: 6)
        Result.calc_request_data(@result)
      end

      it 'not change time cutting' do
        Result.update_and_recalculate(@result, {project: @result.project_id,
                                                version: @result.version,
                                                duration: @result.duration,
                                                test_run_date: @result.test_run_date,
                                                rps: @result.rps,
                                                profile: @result.profile,
                                                time_cutting_percent: '10'})
        expect(CalculatedRequestsResult.where(result_id: @result.id).pluck(:mean)[0]).to eql 377.67
      end

      it 'change time cutting' do
        Result.update_and_recalculate(@result, {project: @result.project_id,
                                                version: @result.version,
                                                duration: @result.duration,
                                                test_run_date: @result.test_run_date,
                                                rps: @result.rps,
                                                profile: @result.profile,
                                                time_cutting_percent: '1'})
        expect(CalculatedRequestsResult.where(result_id: @result.id).pluck(:mean)[0]).to eql 314.0
      end
    end

    describe 'Update and recalculate only with request and performance data' do
      before(:all) do
        @result = create(:result, time_cutting_percent: 10)
        create(:requests_result, result_id: @result.id, timestamp: 1455023029547, value: 2)
        create(:requests_result, result_id: @result.id, timestamp: 1455023039548, value: 123)
        create(:requests_result, result_id: @result.id, timestamp: 1455023040000, value: 123)
        create(:requests_result, result_id: @result.id, timestamp: 1455023045000, value: 121)
        create(:requests_result, result_id: @result.id, timestamp: 1455023050000, value: 1000)
        create(:requests_result, result_id: @result.id, timestamp: 1455023055000, value: 12)
        create(:requests_result, result_id: @result.id, timestamp: 1455023060000, value: 12)
        create(:requests_result, result_id: @result.id, timestamp: 1455023070001, value: 6)
        create(:performance_result, result_id: @result.id, timestamp: 1455023029547, value: 2)
        create(:performance_result, result_id: @result.id, timestamp: 1455023039548, value: 123)
        create(:performance_result, result_id: @result.id, timestamp: 1455023040000, value: 123)
        create(:performance_result, result_id: @result.id, timestamp: 1455023045000, value: 121)
        create(:performance_result, result_id: @result.id, timestamp: 1455023050000, value: 1000)
        create(:performance_result, result_id: @result.id, timestamp: 1455023055000, value: 12)
        create(:performance_result, result_id: @result.id, timestamp: 1455023060000, value: 12)
        create(:performance_result, result_id: @result.id, timestamp: 1455023070001, value: 6)
        Result.calc_request_data(@result)
        Result.calc_performance_data(@result)
      end

      it 'not change time cutting' do
        Result.update_and_recalculate(@result, {project: @result.project_id,
                                                version: @result.version,
                                                duration: @result.duration,
                                                test_run_date: @result.test_run_date,
                                                rps: @result.rps,
                                                profile: @result.profile,
                                                time_cutting_percent: '10'})
        expect(CalculatedPerformanceResult.where(result_id: @result.id).pluck(:mean)[0]).to eql 231.83
      end

      it 'change time cutting' do
        Result.update_and_recalculate(@result, {project: @result.project_id,
                                                version: @result.version,
                                                duration: @result.duration,
                                                test_run_date: @result.test_run_date,
                                                rps: @result.rps,
                                                profile: @result.profile,
                                                time_cutting_percent: '0'})
        expect(CalculatedPerformanceResult.where(result_id: @result.id).pluck(:mean)[0]).to eql 174.88
      end

      it 'change value smoothing interval' do
        Result.update_and_recalculate(@result, {project: @result.project_id,
                                                version: @result.version,
                                                duration: @result.duration,
                                                test_run_date: @result.test_run_date,
                                                rps: @result.rps,
                                                profile: @result.profile,
                                                smoothing_percent: 3,
                                                time_cutting_percent: '10'})
        expect(CalculatedPerformanceResult.where(result_id: @result.id).pluck(:mean)[0]).to eql 231.83
      end


    end

    describe 'some parameters absence or invalid' do
      before(:all) do
        @summary = Tempfile.new('requests_data_temp')
        @perfmon = Tempfile.new('perfmon_data_temp')
        File.open(File.join(fixture_path, 'summary.csv'), 'r') do |f|
          @summary.write f.read
        end
        File.open(File.join(fixture_path, 'perfmon.csv'), 'r') do |f|
          @perfmon.write f.read
        end
        @summary.close
        @perfmon.close
        @summary.open
        @perfmon.open
        performance_data = ActionDispatch::Http::UploadedFile.new(tempfile: @perfmon, filename: 'perfmon.csv')
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary, filename: 'summary.csv')
        params = {
            'project' => 1,
            'version' => 'edu',
            'rps' => 150,
            'duration' => 123,
            'profile' => 'asd',
            'test_run_date' => '2016-02-11 11:21',
            'requests_data' => requests_data,
            'performance_data' => performance_data
        }

        @result = Result.upload_and_create(params)
        @summary.close
        @perfmon.close
      end

      it 'version is absence' do
        @summary.open
        @perfmon.open
        performance_data = ActionDispatch::Http::UploadedFile.new(tempfile: @perfmon, filename: 'perfmon.csv')
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary, filename: 'summary.csv')
        params = {
            :project => 1,
            :rps => 150,
            :duration => 123,
            :profile => 'asd',
            :test_run_date => '2016-02-11 11:21',
            :release_date => '2016-02-11 11:21',
            :requests_data => requests_data,
            :performance_data => performance_data
        }
        updated_result = Result.update_and_recalculate(@result, params)
        @summary.close
        @perfmon.close


        expect(updated_result.errors.full_messages).to include("Version can't be blank")
      end

      it 'absence required columns in request data' do
        @invalid_summary = Tempfile.new('requests_data_temp')
        File.open(File.join(fixture_path, 'summary_invalid_header.csv'), 'r') do |f|
          @invalid_summary.write f.read
        end
        @invalid_summary.close
        @invalid_summary.open
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @invalid_summary, filename: 'summary_invalid_header.csv')
        params = {
            project: 1,
            version: 'test',
            rps: 150,
            duration: 123,
            profile: 'asd',
            test_run_date: '2016-02-11 11:21',
            requests_data: requests_data
        }

        updated_result = Result.update_and_recalculate(@result, params)
        @invalid_summary.close

        expected_errors =['timeStamp column in request data is required!',
                          'label column in request data is required!',
                          'responseCode column in request data is required!',
                          'Latency column in request data is required!']
        expect(updated_result.errors.full_messages).to match_array(expected_errors)
      end
    end


  end
end
