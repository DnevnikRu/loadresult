require 'csv'

class Result < ActiveRecord::Base
  has_many :performance_results, dependent: :delete_all
  has_many :requests_results, dependent: :delete_all
  has_many :calculated_requests_results, dependent: :delete_all
  has_many :calculated_performance_results, dependent: :delete_all

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
      if params['requests_data'].is_a?(Hash)
        file_from_json(params, 'requests_data')
      end
      result.destroy unless save_request_data(params['requests_data'], result)
    else
      result.destroy
      result.errors.add(:base, 'Request data is required')
    end

    if params['perfmon_data']
      if params['perfmon_data'].is_a?(Hash)
        file_from_json(params, 'perfmon_data')
      end
      result.destroy unless save_perfmon_data(params['perfmon_data'], result)
    end

    unless result.errors.any?
      calc_request_data(result)
      calc_performance_data(result) unless result.performance_results.empty?
    end

    result
  end

  def self.calc_request_data(result)
    bottom_timestamp, top_timestamp = result.class.border_timestamps(result.id, RequestsResult)
    labels = RequestsResult.where(result_id: result.id).pluck(:label).uniq
    labels.each do |label|
      CalculatedRequestsResult.create(
          result_id: result.id,
          label: label,
          mean: result.request_mean(label, bottom_timestamp, top_timestamp),
          median: result.request_median(label, bottom_timestamp, top_timestamp),
          ninety_percentile: result.request_90percentile(label, bottom_timestamp, top_timestamp),
          max: result.request_max(label, bottom_timestamp, top_timestamp),
          min: result.request_min(label, bottom_timestamp, top_timestamp),
          throughput: result.request_throughput(label, bottom_timestamp, top_timestamp),
          failed_results: result.failed_requests(label, bottom_timestamp, top_timestamp)
      )
    end
  end

  def self.calc_performance_data(result)
    bottom_timestamp, top_timestamp = result.class.border_timestamps(result.id, PerformanceResult)
    labels = PerformanceResult.where(result_id: result.id).pluck(:label).uniq
    labels.each do |label|
      CalculatedPerformanceResult.create(
          result_id: result.id,
          label: label,
          mean: result.performance_mean(label, bottom_timestamp, top_timestamp),
          max: result.performance_max(label, bottom_timestamp, top_timestamp),
          min: result.performance_min(label, bottom_timestamp, top_timestamp)
      )
    end
  end

  def request_mean(label, bottom_timestamp, top_timestamp)
    records = RequestsResult.where(self.class.where_conditional(id, label, bottom_timestamp, top_timestamp))
    records.exists? ? records.average(:value).round(2) : nil
  end

  def request_median(label, bottom_timestamp, top_timestamp)
    records = RequestsResult.where(self.class.where_conditional(id, label, bottom_timestamp, top_timestamp))
    records.exists? ? median(records.pluck(:value)) : nil
  end

  def request_90percentile(label, bottom_timestamp, top_timestamp)
    records = RequestsResult.where(self.class.where_conditional(id, label, bottom_timestamp, top_timestamp))
    records.exists? ? self.class.percentile(records.pluck(:value), 90) : nil
  end

  def request_min(label, bottom_timestamp, top_timestamp)
    records = RequestsResult.where(self.class.where_conditional(id, label, bottom_timestamp, top_timestamp))
    records.exists? ? records.minimum(:value) : nil
  end

  def request_max(label, bottom_timestamp, top_timestamp)
    records = RequestsResult.where(self.class.where_conditional(id, label, bottom_timestamp, top_timestamp))
    records.exists? ? records.maximum(:value) : nil
  end

  def request_throughput(label, bottom_timestamp, top_timestamp)
    duration = (top_timestamp - bottom_timestamp)
    duration = (duration == 0 || duration / 1000.0 <= 1) ? 1 : duration / 1000.0
    records = RequestsResult.where(self.class.where_conditional(id, label, bottom_timestamp, top_timestamp))
    records.exists? ? (records.count.to_f / duration.to_f).round(2) : nil
  end

  def failed_requests(label, bottom_timestamp, top_timestamp)
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

  def performance_mean(label, bottom_timestamp, top_timestamp)
    records = PerformanceResult.where(self.class.where_conditional(id, label, bottom_timestamp, top_timestamp))
    records.exists? ? records.average(:value).round(2) : nil
  end

  def performance_min(label, bottom_timestamp, top_timestamp)
    records = PerformanceResult.where(self.class.where_conditional(id, label, bottom_timestamp, top_timestamp))
    records.exists? ? records.minimum(:value) : nil
  end

  def performance_max(label, bottom_timestamp, top_timestamp)
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
    where_request = []
    where_request.push "result_id = #{id}" if id
    where_request.push "label = '#{label}'" if label
    where_request.push "timestamp >= #{bottom_timestamp}" if bottom_timestamp
    where_request.push "timestamp <= #{top_timestamp}" if top_timestamp
    where_request.size > 1 ? where_request.join(' AND ') : where_request.join
  end

  def self.percentile(data, percent)
    return 0 if percent == 0

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

  def self.values_of_requests(result_id, label = nil)
    bottom_timestamp, top_timestamp = border_timestamps(result_id, RequestsResult)
    records = RequestsResult.where(where_conditional(result_id, label, bottom_timestamp, top_timestamp))
    records.map(&:value)
  end

  def self.percentile_of_values_of_requests(result_id)
    values = values_of_requests(result_id)
    (0..100).map { |i| percentile(values, i) }
  end

  def self.performance_plot(result_id, performance_group)
    data = {}
    performance_group.labels.each do |label_main|
      label_main_label = handle_backslash(label_main.label)
      labels = find_performance_result_labels(label_main_label).uniq
      labels.each do |label|
        data[label] = {seconds: [], values: []}
        bottom_timestamp, top_timestamp = border_timestamps(result_id, PerformanceResult)
        records = PerformanceResult.where(where_conditional(result_id, label, bottom_timestamp, top_timestamp))
        timestamp_min = records.minimum(:timestamp)
        records.order(:timestamp).each do |record|
          data[label][:seconds].push (record.timestamp - timestamp_min) / 1000
          data[label][:values].push record.value
        end
      end
    end
    data
  end

  private

  def self.file_from_json(params, data)
    file_hash = params[data]
    tempfile = Tempfile.new('file')
    tempfile.binmode
    tempfile.write(Base64.decode64(file_hash[:file]))
    tempfile.rewind
    mime_type = Mime::Type.lookup_by_extension(File.extname(file_hash[:filename])[1..-1]).to_s
    real_file = ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile, :filename => file_hash[:filename], :type => mime_type)
    params[data] = real_file
  end

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

  def self.handle_backslash(str)
    str.gsub('\\') { '\\\\' }
  end

  def self.find_performance_result_labels(label)
    PerformanceResult.where('label LIKE ?', "%#{label}%").pluck(:label)
  end
end
