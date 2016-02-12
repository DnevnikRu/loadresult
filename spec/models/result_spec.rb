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
      File.open(File.expand_path('../../resources/summary.csv', __FILE__), 'r') do |f|
        @summary.write f.read
      end
      File.open(File.expand_path('../../resources/perfmon.csv', __FILE__), 'r') do |f|
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
            'date' => ['2016-02-11 11:21'],
            'request_data' => requests_data,
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
    end

    describe 'some parameters absence' do
      it 'perfmon data is absence' do
        @summary.open
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary)
        params = {
            'version' => 'edu',
            'rps' => 150,
            'duration' => 123,
            'profile' => 'asd',
            'date' => ['2016-02-11 11:21'],
            'request_data' => requests_data
        }
        result = Result.upload_and_create(params)
        expect(result.errors).to be_empty
        @summary.close
      end

      it 'version is absence, other required fields presence' do
        @summary.open
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary)
        params = {
            'rps' => 150,
            'duration' => 123,
            'profile' => 'asd',
            'date' => ['2016-02-11 11:21'],
            'request_data' => requests_data
        }
        result = Result.upload_and_create(params)
        expect(result.errors).to match_array(["Version can't be blank"])
        @summary.close
      end

      it 'rps is absence, other required fields presence' do
        @summary.open
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary)
        params = {
            'version' => 'asd',
            'duration' => 123,
            'profile' => 'asd',
            'date' => ['2016-02-11 11:21'],
            'request_data' => requests_data
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
            'date' => ['2016-02-11 11:21'],
            'request_data' => requests_data
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
            'date' => ['2016-02-11 11:21'],
            'request_data' => requests_data
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
            'request_data' => requests_data,
            'date' => ['']
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
            'date' => ['2016-02-11 11:21']
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
       File.open(File.expand_path('../../resources/summary_invalid_header.csv', __FILE__), 'r') do |f|
         @invalid_summary.write f.read
       end
       File.open(File.expand_path('../../resources/perfmon_invalid_header.csv', __FILE__), 'r') do |f|
         @invalid_perfmon.write f.read
       end
       @invalid_summary.close
       @invalid_perfmon.close
     end

      it 'absence required columns in request data' do
        @invalid_summary.open
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @invalid_summary)
        params = {
            'version' => 'edu',
            'rps' => 150,
            'duration' => 123,
            'profile' => 'asd',
            'date' => ['2016-02-11 11:21'],
            'request_data' => requests_data
        }

        result = Result.upload_and_create(params)
        @invalid_summary.close
        errors = []
        required_column = %w(timeStamp label responseCode Latency)
        required_column.each do |column|
          errors.push "#{column} column in request data is required!"
        end
        expect(result.errors).to match_array(errors)
      end

      it 'absence required columns in perfmon data' do
        @summary.open
        @invalid_perfmon.open
        perfmon_data = ActionDispatch::Http::UploadedFile.new(tempfile: @invalid_perfmon)
        requests_data = ActionDispatch::Http::UploadedFile.new(tempfile: @summary)
        params = {
            'version' => 'edu',
            'rps' => 150,
            'duration' => 123,
            'profile' => 'asd',
            'date' => ['2016-02-11 11:21'],
            'request_data' => requests_data,
            'perfmon_data' => perfmon_data
        }

        result = Result.upload_and_create(params)
        @summary.close
        @invalid_perfmon.close
        errors = []
        required_column = %w(timeStamp label elapsed)
        required_column.each do |column|
          errors.push "#{column} column in perfmon data is required!"
        end
        expect(result.errors).to match_array(errors)
      end
    end
  end
end