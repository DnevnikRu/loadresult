require 'csv'

class Result < ActiveRecord::Base
  has_many :performance_results
  has_many :requests_results

  validates :version, presence: true
  validates :duration, presence: true
  validates :rps, presence: true
  validates :profile, presence: true
  validate :test_run_date_is_datetime

  def test_run_date_is_datetime
    errors.add(:test_run_date, 'must be in a datetime format') if test_run_date.nil?
  end

  def self.upload_and_create(params)
    result = Result.new(version: params['version'], duration: params['duration'], rps: params['rps'], profile: params['profile'], test_run_date: params['date'].first)
    return result unless result.save
    unless params['request_data']
      result.errors.add(:base, 'Request data is required')
      return result
    end
    return result unless save_request_data(params['request_data'], result) # do not save perfmon data unless request data saved
    save_perfmon_data(params['perfmon_data'], result) if params['perfmon_data']
    result
  end

  private

  def self.validate_header(result, header, data_type, required_fields)
    required_fields.each do |column_name|
      result.errors.add(:base, "#{column_name} column in #{data_type} data is required!") unless header.include?(column_name)
    end
  end

  def self.save_request_data(request_data, result)
    request_data = CSV.new(request_data.read)
    header = request_data.first
    validate_header(result, header, 'request', %w(timeStamp label responseCode Latency)) # TODO: move list of required column to model
    return nil unless result.errors.empty?
    columns_indexes = csv_header_columns_indexes(header)
    request_data.each do |line|
      requests_result = RequestsResult.new
      requests_result.result_id = result.id
      requests_result.timestamp = line[columns_indexes['timeStamp']]
      requests_result.label = line[columns_indexes['label']]
      requests_result.response_code = line[columns_indexes['responseCode']]
      requests_result.value = line[columns_indexes['Latency']]
      requests_result.save
    end
    result
  end

  def self.save_perfmon_data(perfmon_data, result)
    perfmon_data = CSV.new(perfmon_data.read)
    header = perfmon_data.first
    validate_header(result, header, 'perfmon', %w(timeStamp label elapsed)) # TODO: move list of required column to model
    return nil unless result.errors.empty?
    columns_indexes = csv_header_columns_indexes(header)
    perfmon_data.each do |line|
      performance_result = PerformanceResult.new
      performance_result.result_id = result.id
      performance_result.timestamp = line[columns_indexes['timeStamp']]
      performance_result.label = line[columns_indexes['label']]
      performance_result.value = line[columns_indexes['elapsed']]
      performance_result.save
    end
    result
  end

  def self.csv_header_columns_indexes(header)
    indexes = {}
    header.each_index do |i|
      indexes[header[i]] = i
    end
    indexes
  end
end
