require 'csv'

class Result < ActiveRecord::Base
  has_many :performance_results
  has_many :requests_results
  has_many :calculated_requests_results
  has_many :calculated_performance_results

  validates :version, presence: true
  validates :duration, presence: true
  validates :rps, presence: true
  validates :profile, presence: true
  validate :test_run_date_is_datetime

  def test_run_date_is_datetime
    errors.add(:test_run_date, 'must be in a datetime format') if test_run_date.nil?
  end

  def self.upload_and_create(params)
    result = Result.new(
        version: params['version'],
        duration: params['duration'],
        rps: params['rps'],
        profile: params['profile'],
        test_run_date: params['test_run_date']
    )
    result.save

    if params['requests_data']
      result.destroy unless save_request_data(params['requests_data'], result)
    else
      result.destroy
      result.errors.add(:base, 'Request data is required')
    end

    if params['perfmon_data']
      result.destroy unless save_perfmon_data(params['perfmon_data'], result)
    end

    #  unless result.errors.any?
    #    calc_request_data(result)
    #    calc_perfmon_data(result) unless result.performance_results.empty?
    #  end

    result
  end

  # def self.calc_request_data(result)
  #   labels = RequestsResult.where(result_id: result.id).pluck(:label)
  #   labels.each do |label|
  #     RequestsResultCalculated.create(
  #         result_id: result.id,
  #         label: label,
  #         mean: request_mean(label)
  #     )

  #   end
  # end

  def request_mean(label)
    bottom_timestamp, top_timestamp = self.class.border_timestamps(id, RequestsResult)
    records = RequestsResult.where(self.class.where_conditional(id, label, bottom_timestamp, top_timestamp))
    records.exists? ? records.average(:value).round(2) : nil
  end

  def request_median(label)
    bottom_timestamp, top_timestamp = self.class.border_timestamps(id, RequestsResult)
    records = RequestsResult.where(self.class.where_conditional(id, label, bottom_timestamp, top_timestamp))
    records.exists? ? median(records.pluck(:value)) : nil
  end

  def request_90percentile(label)
    bottom_timestamp, top_timestamp = self.class.border_timestamps(id, RequestsResult)
    records = RequestsResult.where(self.class.where_conditional(id, label, bottom_timestamp, top_timestamp))
    records.exists? ? percentile(records.pluck(:value), 90) : nil
  end

  def request_min(label)
    bottom_timestamp, top_timestamp = self.class.border_timestamps(id, RequestsResult)
    records = RequestsResult.where(self.class.where_conditional(id, label, bottom_timestamp, top_timestamp))
    records.exists? ? records.minimum(:value) : nil
  end

  def request_max(label)
    bottom_timestamp, top_timestamp = self.class.border_timestamps(id, RequestsResult)
    records = RequestsResult.where(self.class.where_conditional(id, label, bottom_timestamp, top_timestamp))
    records.exists? ? records.maximum(:value) : nil
  end

  def request_throughput(label)
    bottom_timestamp, top_timestamp = self.class.border_timestamps(id, RequestsResult)
    duration = (top_timestamp - bottom_timestamp)
    duration = duration == 0 || duration / 1000.0 <= 1 ? 1 : duration / 1000.0
    records = RequestsResult.where(self.class.where_conditional(id, label, bottom_timestamp, top_timestamp))
    records.exists? ? (records.count.to_f / duration.to_f).round(2) : nil
  end

  def failed_requests(label)
    bottom_timestamp, top_timestamp = self.class.border_timestamps(id, RequestsResult)
    records = RequestsResult.where(self.class.where_conditional(id, label, bottom_timestamp, top_timestamp))
    if records.exists?
      int_codes = records.pluck(:response_code).map { |code| code.to_i }
      client_errors = int_codes.count { |code| code.between?(400, 499) }
      server_errors = int_codes.count { |code| code.between?(500, 599) }
      unrecognized_errors = int_codes.count { |code| code == 0 }
      failed_count = client_errors + server_errors + unrecognized_errors
      ((failed_count.to_f / int_codes.count) * 100).round(2)
    end
  end

  def performance_mean(label)
    bottom_timestamp, top_timestamp = self.class.border_timestamps(id, PerformanceResult)
    records = PerformanceResult.where(self.class.where_conditional(id, label, bottom_timestamp, top_timestamp))
    records.exists? ? records.average(:value).round(2) : nil
  end

  def performance_min(label)
    bottom_timestamp, top_timestamp = self.class.border_timestamps(id, PerformanceResult)
    records = PerformanceResult.where(self.class.where_conditional(id, label, bottom_timestamp, top_timestamp))
    records.exists? ? records.minimum(:value) : nil
  end

  def performance_max(label)
    bottom_timestamp, top_timestamp = self.class.border_timestamps(id, PerformanceResult)
    records = PerformanceResult.where(self.class.where_conditional(id, label, bottom_timestamp, top_timestamp))
    records.exists? ? records.maximum(:value) : nil
  end

  def self.border_timestamps(id, table)
    max_timestamp = table.where(result_id: id).maximum(:timestamp)
    min_timestamp = table.where(result_id: id).minimum(:timestamp)
    ten_percent = (max_timestamp - min_timestamp) / 10
    bottom_timestamp = (min_timestamp + ten_percent)
    top_timestamp = (max_timestamp - ten_percent)
    [bottom_timestamp, top_timestamp]
  end

  def self.where_conditional(id, label, bottom_timestamp, top_timestamp)
    "result_id = #{id} and label = '#{label}' and timestamp > #{bottom_timestamp} and timestamp < #{top_timestamp}"
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
      '#{line[header.index('label')]}', #{line[header.index('elapsed')].to_i / 1000},
       '#{Time.now}', '#{Time.now}')"
    end
    ActiveRecord::Base.connection.execute(%(INSERT INTO performance_results (result_id, timestamp, label, value, created_at, updated_at)
                                            VALUES #{perfmons_data.join(', ')}))
    result
  end

  def median(data)
    sorted_array = data.sort
    rank = data.length * 0.5
    exactly_divide_check = rank - rank.to_i
    if exactly_divide_check.eql? 0.0
      first = (sorted_array[rank - 1]).to_f
      second = (sorted_array[rank]).to_f
      (first + second) / 2
    else
      sorted_array[rank]
    end
  end

  def percentile(data, percent)
    sorted_array = data.sort
    rank = percent.to_f / 100 * data.length
    exactly_divide_check = rank - rank.to_i
    if data.empty?
      nil
    elsif exactly_divide_check.eql? 0.0
      sorted_array[rank - 1]
    else
      first = (sorted_array[rank - 1]).to_f
      second = (sorted_array[rank]).to_f
      (first + second) / 2
    end
  end
end
