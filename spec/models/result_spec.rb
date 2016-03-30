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
        perfmon_data = ActionDispatch::Http::UploadedFile.new(tempfile: @perfmon)
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary)
        params = {
            'version' => 'edu',
            'rps' => 150,
            'duration' => 123,
            'profile' => 'asd',
            'test_run_date' => '2016-02-11 11:21',
            'requests_data' => requests_data,
            'perfmon_data' => perfmon_data
        }

        @result = Result.upload_and_create(params)
        @summary.close
        @perfmon.close
      end

      it 'empty errors' do
        expect(@result.errors).to be_empty
      end

      it 'result saved' do
        expect(Result.find(@result.id)).not_to be_nil
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

    end

    describe 'some parameters absence' do
      describe 'perfmon data is absence' do
        before(:all) do
          @summary.open
          requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary)
          params = {
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

      describe 'version is absence, other required fields presence' do
        before(:all) do
          @summary.open
          @perfmon.open
          perfmon_data = ActionDispatch::Http::UploadedFile.new(tempfile: @perfmon)
          requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary)
          params = {
              'rps' => 150,
              'duration' => 123,
              'profile' => 'asd',
              'test_run_date' => '2016-02-11 11:21',
              'requests_data' => requests_data,
              'perfmon_data' => perfmon_data
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

      it 'rps is absence, other required fields presence' do
        @summary.open
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary)
        params = {
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
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary)
        params = {
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
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary)
        params = {
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
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary)
        params = {
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
          requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @invalid_summary)
          params = {
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
          perfmon_data = ActionDispatch::Http::UploadedFile.new(tempfile: @invalid_perfmon)
          requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary)
          params = {
              'version' => 'edu',
              'rps' => 150,
              'duration' => 123,
              'profile' => 'asd',
              'test_run_date' => '2016-02-11 11:21',
              'requests_data' => requests_data,
              'perfmon_data' => perfmon_data
          }

          @result = Result.upload_and_create(params)
          @summary.close
          @invalid_perfmon.close
        end

        it 'result include correct errors' do
          errors = []
          required_column = %w(timeStamp label elapsed)
          required_column.each do |column|
            errors.push "#{column} column in perfmon data is required!"
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

  describe '#timestamps and request calculate with nonexistent label' do

    before(:all) do
      @result = create(:result)
      create(:requests_result, result_id: @result.id, timestamp: 1455023039548)
      create(:requests_result, result_id: @result.id, timestamp: 1455023040000)
      create(:requests_result, result_id: @result.id, timestamp: 1455023045000)
      create(:requests_result, result_id: @result.id, timestamp: 1455023050000)
      create(:requests_result, result_id: @result.id, timestamp: 1455023055000)
      create(:requests_result, result_id: @result.id, timestamp: 1455023060000)
      @bottom_timestamp, @top_timestamp = @result.class.border_timestamps(@result.id, RequestsResult, 10)
    end

    it 'timestamp borders are correct' do
      expect([@bottom_timestamp, @top_timestamp]).to match_array([1455023041593, 1455023057955])
    end

    it 'request mean is nill with wrong label' do
      expect(@result.request_mean('root /invites.aspx:GET', @bottom_timestamp, @top_timestamp)).to eql nil
    end
    it 'request median is nill with wrong label' do
      expect(@result.request_median('root /invites.aspx:GET', @bottom_timestamp, @top_timestamp)).to eql nil
    end
    it 'request 90 percent is nill with wrong label' do
      expect(@result.request_90percentile('root /invites.aspx:GET', @bottom_timestamp, @top_timestamp)).to eql nil
    end
    it 'request max is nill with wrong label' do
      expect(@result.request_max('root /invites.aspx:GET', @bottom_timestamp, @top_timestamp)).to eql nil
    end
    it 'request min is nill with wrong label' do
      expect(@result.request_min('root /invites.aspx:GET', @bottom_timestamp, @top_timestamp)).to eql nil
    end
    it 'request failed tests percentage is nill with wrong label' do
      expect(@result.failed_requests('root /invites.aspx:GET', @bottom_timestamp, @top_timestamp)).to eql nil
    end
    it 'request throughput is nill with wrong label' do
      expect(@result.request_throughput('root /invites.aspx:GET', @bottom_timestamp, @top_timestamp)).to eql nil
    end
  end

  describe '#request calculate with standard values' do

    before(:all) do
      @result = create(:result)
      create(:requests_result, result_id: @result.id, timestamp: 1455023040000, value: 123, response_code: 600)
      create(:requests_result, result_id: @result.id, timestamp: 1455023045000, value: 1400, response_code: 500)
      create(:requests_result, result_id: @result.id, timestamp: 1455023050500, value: 1, response_code: 499)
      create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 346, response_code: 400)
      create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 345, response_code: 599)
      create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 344, response_code: 399)
      create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 343, response_code: 501)
      create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 342, response_code: 401)
      create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 341, response_code: 200)
      create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 348, response_code: 100)
      create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 1238, response_code: 123)
      create(:requests_result, result_id: @result.id, timestamp: 1455023060000, value: 123, response_code: 9880)
      @bottom_timestamp, @top_timestamp = @result.class.border_timestamps(@result.id, RequestsResult, 10)
    end

    it 'request mean is correct with standard values' do
      expect(@result.request_mean('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 504.8
    end
    it 'request median is correct with standard values' do
      expect(@result.request_median('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 344.5
    end
    it 'request 90 percent is correct with standard values' do
      expect(@result.request_90percentile('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 1238
    end
    it 'request max is correct with standard values' do
      expect(@result.request_max('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 1400
    end
    it 'request min is correct with standard values' do
      expect(@result.request_min('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 1
    end
    it 'failed tests percentage is correct with standard values' do
      expect(@result.failed_requests('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 60.0
    end
  end

  describe '#request calculate with different values' do

    before(:all) do
      @result = create(:result)
      create(:requests_result, result_id: @result.id, timestamp: 1455023040000, value: 123, response_code: 600)
      create(:requests_result, result_id: @result.id, timestamp: 1455023045000, value: 0, response_code: 500)
      create(:requests_result, result_id: @result.id, timestamp: 1455023050500, value: 0.1, response_code: 499)
      create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 346, response_code: nil)
      create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 345, response_code: 599)
      create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 344, response_code: 'Non HTTP response code: org.apache.http.ConnectionClosedException')
      create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 343, response_code: 1)
      create(:requests_result, result_id: @result.id, timestamp: 1455023060000, value: 123, response_code: 9880)
      @bottom_timestamp, @top_timestamp = @result.class.border_timestamps(@result.id, RequestsResult, 10)
    end

    it 'request mean is correct with different values' do
      expect(@result.request_mean('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 229.67
    end
    it 'request median is correct with different values' do
      expect(@result.request_median('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 343.5
    end
    it 'request 90 percent is correct with different values' do
      expect(@result.request_90percentile('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 345.5
    end
    it 'request max is correct with different values' do
      expect(@result.request_max('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 346
    end
    it 'request min is correct with different values' do
      expect(@result.request_min('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 0
    end
    it 'failed tests percentage is correct with different values' do
      expect(@result.failed_requests('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 83.33
    end
  end

  describe '#request calculate with same values' do

    before(:all) do
      @result = create(:result)
      create(:requests_result, result_id: @result.id, timestamp: 1455023040000, value: 123, response_code: 123)
      create(:requests_result, result_id: @result.id, timestamp: 1455023045000, value: 123, response_code: 123)
      create(:requests_result, result_id: @result.id, timestamp: 1455023047500, value: 123, response_code: 123)
      create(:requests_result, result_id: @result.id, timestamp: 1455023050500, value: 123, response_code: 123)
      create(:requests_result, result_id: @result.id, timestamp: 1455023050600, value: 123, response_code: 123)
      create(:requests_result, result_id: @result.id, timestamp: 1455023050601, value: 123, response_code: 123)
      @bottom_timestamp, @top_timestamp = @result.class.border_timestamps(@result.id, RequestsResult, 10)
    end

    it 'request mean is correct with same values' do
      expect(@result.request_mean('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 123.0
    end
    it 'request median is correct with same values' do
      expect(@result.request_median('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 123.0
    end
    it 'request 90 percent is correct with same values' do
      expect(@result.request_90percentile('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 123.0
    end
    it 'request max is correct with same values' do
      expect(@result.request_max('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 123
    end
    it 'request min is correct with same values' do
      expect(@result.request_min('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 123
    end
    it 'failed tests percentage is correct with same values' do
      expect(@result.failed_requests('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 0.0
    end
  end

  describe '#request throughput with different timestamps' do

    before(:all) do
      @result = create(:result)
      create(:requests_result, result_id: @result.id, timestamp: 1455023040000)
      create(:requests_result, result_id: @result.id, timestamp: 1455023040600)
      create(:requests_result, result_id: @result.id, timestamp: 1455023040700)
      create(:requests_result, result_id: @result.id, timestamp: 1455023040800)
      create(:requests_result, result_id: @result.id, timestamp: 1455023040900)
      create(:requests_result, result_id: @result.id, timestamp: 1455023041000)
      create(:requests_result, result_id: @result.id, timestamp: 1455023041100)
      create(:requests_result, result_id: @result.id, timestamp: 1455023041200)
      create(:requests_result, result_id: @result.id, timestamp: 1455023041300)
      create(:requests_result, result_id: @result.id, timestamp: 1455023041400)
      create(:requests_result, result_id: @result.id, timestamp: 1455023041500)
      create(:requests_result, result_id: @result.id, timestamp: 1455023041600)
      @bottom_timestamp, @top_timestamp = @result.class.border_timestamps(@result.id, RequestsResult, 10)
    end

    it 'request throughput with different timestamps' do
      expect(@result.request_throughput('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 7.03
    end
  end

  describe '#request throughput with same timestamps' do

    before(:all) do
      @result = create(:result)
      create(:requests_result, result_id: @result.id, timestamp: 1455023040500)
      create(:requests_result, result_id: @result.id, timestamp: 1455023040600)
      create(:requests_result, result_id: @result.id, timestamp: 1455023040600)
      create(:requests_result, result_id: @result.id, timestamp: 1455023040600)
      create(:requests_result, result_id: @result.id, timestamp: 1455023040600)
      create(:requests_result, result_id: @result.id, timestamp: 1455023040700)
      @bottom_timestamp, @top_timestamp = @result.class.border_timestamps(@result.id, RequestsResult, 10)
    end

    it 'request throughput with same timestamps' do
      expect(@result.request_throughput('children /marks.aspx:GET:tab=subject', @bottom_timestamp, @top_timestamp)).to eql 4.0
    end
  end


  describe '#perfomance calculate with correct values and with not existent label' do

    before(:all) do
      @result = create(:result)
      create(:performance_result, result_id: @result.id, timestamp: 1455023039548, value: 2)
      create(:performance_result, result_id: @result.id, timestamp: 1455023040000, value: 123)
      create(:performance_result, result_id: @result.id, timestamp: 1455023045000, value: 121)
      create(:performance_result, result_id: @result.id, timestamp: 1455023050000, value: 1000)
      create(:performance_result, result_id: @result.id, timestamp: 1455023055000, value: 12)
      create(:performance_result, result_id: @result.id, timestamp: 1455023060000, value: 6)
      @bottom_timestamp, @top_timestamp = @result.class.border_timestamps(@result.id, PerformanceResult, 10)
    end

    it 'performance mean is correct' do
      expect(@result.performance_mean('EXEC Network\Bytes Sent/sec', @bottom_timestamp, @top_timestamp)).to eql 377.67
    end

    it 'performance minimum is correct' do
      expect(@result.performance_min('EXEC Network\Bytes Sent/sec', @bottom_timestamp, @top_timestamp)).to eql 12
    end

    it 'performance maximum is correct' do
      expect(@result.performance_max('EXEC Network\Bytes Sent/sec', @bottom_timestamp, @top_timestamp)).to eql 1000
    end
    it 'performance mean is nill with nonexistent label' do
      expect(@result.performance_mean('EXEC Events\Bytes Sent/sec', @bottom_timestamp, @top_timestamp)).to eql nil
    end

    it 'performance minimum is nill with nonexistent label' do
      expect(@result.performance_min('EXEC Events\Bytes Sent/sec', @bottom_timestamp, @top_timestamp)).to eql nil
    end

    it 'performance maximum is nill with nonexistent label' do
      expect(@result.performance_max('EXEC Events\Bytes Sent/sec', @bottom_timestamp, @top_timestamp)).to eql nil
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
      expect(Result.values_of_requests(@result.id, 'first label', 10)).to eq([3, 4, 5, 6, 7, 8, 9, 10])
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
      perf_seconds_to_values = Result.performance_seconds_to_values(@result.id, ['cpu_1', 'cpu_2'], 10)
      expect(perf_seconds_to_values['cpu_1'][:seconds]).to eq([0, 1, 2, 3, 4, 5, 6, 7, 8])
    end

    it 'cut sent percent from values' do
      perf_seconds_to_values = Result.performance_seconds_to_values(@result.id, ['cpu_1', 'cpu_2'], 10)
      expect(perf_seconds_to_values['cpu_1'][:values]).to eq([1, 2, 3, 4, 5, 6, 7, 8, 9])
    end

    it 'handle all labels' do
      perf_seconds_to_values = Result.performance_seconds_to_values(@result.id, ['cpu_1', 'cpu_2'], 10)
      expect(perf_seconds_to_values).to have_key('cpu_1')
      expect(perf_seconds_to_values).to have_key('cpu_2')
    end
  end

  describe '.border_timestamps' do
    before do
      @result = create(:result)
      (0..10).each do |i|
        create(
            :performance_result,
            result_id: @result.id,
            timestamp: i * 1000
        )
      end
    end

    it 'returns an Array' do
      expect(Result.border_timestamps(@result.id, PerformanceResult, 10)).to be_an(Array)
    end

    it 'returns an minimum and maximum timestamp after cutting a percent' do
      expect(Result.border_timestamps(@result.id, PerformanceResult, 10)).to eq([1000, 9000])
    end
  end

  describe '.percentile' do
    it 'finds percentile of an array' do
      expect(Result.percentile([1, 2, 3, 4], 50)).to eq(2)
    end

    it 'finds percentile of an unsorted array' do
      expect(Result.percentile([3, 1, 2, 4], 50)).to eq(2)
    end

    it 'find percentile of array with odd number of elements' do
      expect(Result.percentile([1, 2, 3, 4, 5], 50)).to eq(2.5)
    end
  end

end
