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

  def request_mean(label)
    bottom_timestamp, top_timestamp = border_timestamps(self.id, RequestsResult)
    (RequestsResult.where("result_id = #{self.id} and label = '#{label}' and timestamp > #{bottom_timestamp} and timestamp < #{top_timestamp}").average(:value)).round(2)
  end

  def request_median(label)
    bottom_timestamp, top_timestamp = border_timestamps(self.id, RequestsResult)
    median(RequestsResult.where("result_id = #{self.id} and label = '#{label}' and timestamp > #{bottom_timestamp} and timestamp < #{top_timestamp}").pluck(:value))
  end

  def request_90percentile(label)
    bottom_timestamp, top_timestamp = border_timestamps(self.id, RequestsResult)
    percentile((RequestsResult.where("result_id = #{self.id} and label = '#{label}' and timestamp > #{bottom_timestamp} and timestamp < #{top_timestamp}").pluck(:value)), 90)
  end

  def request_min(label)
    bottom_timestamp, top_timestamp = border_timestamps(self.id, RequestsResult)
    RequestsResult.where("result_id = #{self.id} and label = '#{label}' and timestamp > #{bottom_timestamp} and timestamp < #{top_timestamp}").minimum(:value)
  end

  def request_max(label)
    bottom_timestamp, top_timestamp = border_timestamps(self.id, RequestsResult)
    RequestsResult.where("result_id = #{self.id} and label = '#{label}' and timestamp > #{bottom_timestamp} and timestamp < #{top_timestamp}").maximum(:value)
  end

  def request_thoughput(label)
    bottom_timestamp, top_timestamp = border_timestamps(self.id, RequestsResult)
    duration = Time.at(top_timestamp).to_time - Time.at(bottom_timestamp).to_time
    request_count = (RequestsResult.where("result_id = #{self.id} and label = '#{label}' and timestamp > #{bottom_timestamp} and timestamp < #{top_timestamp}").count).to_f
    (request_count/duration).round(2)
  end

  def failed_requests(label)
    bottom_timestamp, top_timestamp = border_timestamps(self.id, RequestsResult)
    int_codes = []
    (RequestsResult.where("result_id = #{self.id} and label = '#{label}' and timestamp > #{bottom_timestamp} and timestamp < #{top_timestamp}").pluck(:response_code)).each do |code|
      int_codes.push code.to_i
    end
    client_errors = int_codes.count{|code| code.between?(400, 499)}
    server_errors = int_codes.count{|code| code.between?(500, 599)}
    failed_count = client_errors + server_errors
    ((failed_count.to_f/int_codes.count)*100).round(2)
  end

  def performance_mean(label)
    results = self.performance_results
    bottom_timestamp, top_timestamp = border_timestamps(self.id, PerformanceResult)
    (results.where("result_id = #{self.id} and label = '#{label}' and timestamp > #{bottom_timestamp} and timestamp < #{top_timestamp}").average(:value)).round(2)
  end

  def performance_min(label)
    results = self.performance_results
    bottom_timestamp, top_timestamp = border_timestamps(self.id, PerformanceResult)
    results.where("result_id = #{self.id} and label = '#{label}' and timestamp > #{bottom_timestamp} and timestamp < #{top_timestamp}").minimum(:value)
  end

  def performance_max(label)
    results = self.performance_results
    bottom_timestamp, top_timestamp = border_timestamps(self.id, PerformanceResult)
    results.where("result_id = #{self.id} and label = '#{label}' and timestamp > #{bottom_timestamp} and timestamp < #{top_timestamp}").maximum(:value)
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
    return if result.errors.any?
    requests_results = request_data.map do |line|
      "(#{result.id}, #{line[header.index('timeStamp')]},
       '#{line[header.index('label')]}', '#{line[header.index('responseCode')]}',
       #{line[header.index('Latency')]}, '#{Time.now}', '#{Time.now}')"
    end
    ActiveRecord::Base.connection.execute(%(INSERT INTO requests_results (result_id, timestamp, label, response_code, value, created_at, updated_at)
                                            VALUES #{requests_results.join(', ')}))
    result
  end

  def self.save_perfmon_data(perfmon_data, result)
    perfmon_data = CSV.new(perfmon_data.read)
    header = perfmon_data.first
    validate_header(result, header, 'perfmon', %w(timeStamp label elapsed)) # TODO: move list of required column to model
    return if result.errors.any?
    perfmons_data = perfmon_data.map do |line|
      "(#{result.id}, #{line[header.index('timeStamp')]},
      '#{line[header.index('label')]}', #{line[header.index('elapsed')]},
       '#{Time.now}', '#{Time.now}')"
    end
    ActiveRecord::Base.connection.execute(%(INSERT INTO performance_results (result_id, timestamp, label, value, created_at, updated_at)
                                            VALUES #{perfmons_data.join(', ')}))
    result
  end

  def border_timestamps(id, table)
    min_timestamp = Time.at(table.where("result_id = #{id}").first.timestamp).to_time
    max_timestamp = Time.at(table.where("result_id = #{id}").last.timestamp).to_time
    ten_percent = ((max_timestamp - min_timestamp)*0.10).round
    bottom_timestamp = (min_timestamp + ten_percent).to_i
    top_timestamp = (max_timestamp - ten_percent).to_i
    [bottom_timestamp, top_timestamp]
  end

  def median(data)
    percentile(data, 50)
  end

  def percentile(data, percent)
    sorted_array = data.sort
    rank = (percent.to_f)/100*data.length
    exactly_divide_check = rank.to_f - rank.to_i
    if data.length == 0
      nil
    elsif exactly_divide_check.eql? 0.0
      first = (sorted_array[rank-1]).to_f
      second = (sorted_array[rank]).to_f
      return (first + second)*(percent.to_f)/100
    else
      index = (data.length - 1)*(percent.to_f)/100
      sorted_array[index]
    end
  end

end
