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
    unless params['requests_data']
      result.errors.add(:base, 'Request data is required')
      result.delete
      return result
    end
    unless save_request_data(params['requests_data'], result)
      result.destroy
      return result
    end
    if params['perfmon_data']
      result.destroy unless save_perfmon_data(params['perfmon_data'], result)
    end
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
    requests_results = []
    request_data.each do |line|
      requests_results.push "(#{result.id}, #{line[columns_indexes['timeStamp']]}, '#{line[columns_indexes['label']]}', '#{line[columns_indexes['responseCode']]}', #{line[columns_indexes['Latency']]}, '#{Time.now}', '#{Time.now}')"
    end
    ActiveRecord::Base.connection.execute("insert into requests_results (result_id, timestamp, label, response_code, value, created_at, updated_at) values #{requests_results.join(', ')}")
    result
  end

  def self.save_perfmon_data(perfmon_data, result)
    perfmon_data = CSV.new(perfmon_data.read)
    header = perfmon_data.first
    validate_header(result, header, 'perfmon', %w(timeStamp label elapsed)) # TODO: move list of required column to model
    return nil unless result.errors.empty?
    columns_indexes = csv_header_columns_indexes(header)
    perfmons_data = []
    perfmon_data.each do |line|
      perfmons_data.push "(#{result.id}, #{line[columns_indexes['timeStamp']]}, '#{line[columns_indexes['label']]}', #{line[columns_indexes['elapsed']]}, '#{Time.now}', '#{Time.now}')"
    end
    ActiveRecord::Base.connection.execute("insert into performance_results (result_id, timestamp, label, value, created_at, updated_at) values #{perfmons_data.join(', ')}")
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
