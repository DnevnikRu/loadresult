require 'csv'

class Result < ActiveRecord::Base
  has_many :performance_results, dependent: :delete_all
  has_many :requests_results, dependent: :delete_all
  has_many :calculated_requests_results, dependent: :delete_all
  has_many :calculated_performance_results, dependent: :delete_all
  belongs_to :project

  validates :project_id, presence: true
  validates :version, presence: true
  validates :duration, presence: true
  validates :rps, presence: true
  validates :profile, presence: true
  validate :test_run_date_is_datetime
  validates :value_smoothing_interval, numericality: {only_integer: true}, allow_nil: true
  validate :value_smoothing_interval_cannot_be_even

  mount_uploader :requests_data, ResultUploader
  mount_uploader :performance_data, ResultUploader

  def test_run_date_is_datetime
    errors.add(:test_run_date, 'must be in a datetime format') if test_run_date.nil?
  end

  def value_smoothing_interval_cannot_be_even
    if !value_smoothing_interval.nil? && value_smoothing_interval.even?
      errors.add(:value_smoothing_interval, 'can`t be even')
    end
  end

  def self.upload_and_create(params)
    result = Result.new(
        project_id: params['project'],
        version: params['version'],
        duration: params['duration'],
        rps: params['rps'],
        profile: params['profile'],
        test_run_date: params['test_run_date'],
        requests_data: params['requests_data'].is_a?(Hash) ? file_from_json(params, 'requests_data') : params['requests_data'],
        performance_data: params['performance_data'].is_a?(Hash) ? file_from_json(params, 'performance_data') : params['performance_data'],
        time_cutting_percent: params['time_cutting_percent'].blank? ? 0 : params['time_cutting_percent'],
        value_smoothing_interval: params['value_smoothing_interval']
    )
    result.save

    if result.requests_data.present?
      result.destroy unless save_request_data(result)
    else
      result.destroy
      result.errors.add(:base, 'Request data is required')
    end

    if result.performance_data.present?
      result.destroy unless save_performance_data(result)
    end

    unless result.errors.any?
      calc_request_data(result)
      calc_performance_data(result) unless result.performance_results.empty?
    end

    result
  end

  def self.update_and_recalculate(result, params)
    previous_time_cut_percent = result.time_cutting_percent
    result.update(
        project_id: params[:project],
        version: params[:version],
        rps: params[:rps],
        duration: params[:duration],
        profile: params[:profile],
        time_cutting_percent: params[:time_cutting_percent].blank? ? 0 : params[:time_cutting_percent],
        requests_data: params[:requests_data],
        performance_data: params[:performance_data],
        release_date: params[:release_date]
    )

    update_requests(result,  params[:requests_data],  previous_time_cut_percent)
    update_performance(result,  params[:performance_data], previous_time_cut_percent)

    result
  end

  def self.border_timestamps(id, table, cut_percent)
    max_timestamp = table.where(result_id: id).maximum(:timestamp)
    min_timestamp = table.where(result_id: id).minimum(:timestamp)
    cut_percent = cut_percent.to_f/100
    cutted_time = (max_timestamp - min_timestamp) *cut_percent
    bottom_timestamp = (min_timestamp + cutted_time.to_i)
    top_timestamp = (max_timestamp - cutted_time.to_i)
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

  def self.values_of_requests(result_id, label = nil, cut_percent)
    bottom_timestamp, top_timestamp = border_timestamps(result_id, RequestsResult, cut_percent)
    records = RequestsResult.where(where_conditional(result_id, label, bottom_timestamp, top_timestamp))
    records.map(&:value)
  end

  def self.percentile_of_values_of_requests(result_id, cut_percent)
    values = values_of_requests(result_id, cut_percent)
    (1..100).map { |i| Statistics.percentile(values, i) }
  end

  def self.requests_seconds_to_values(result_id, label, cut_percent)
    data = {seconds: [], values: []}
    bottom_timestamp, top_timestamp = border_timestamps(result_id, RequestsResult, cut_percent)
    records = RequestsResult.where(where_conditional(result_id, label, bottom_timestamp, top_timestamp))
    timestamp_min = records.minimum(:timestamp)
    records.order(:timestamp).each do |record|
      data[:seconds].push (record.timestamp - timestamp_min) / 1000
      data[:values].push record.value
    end
    data
  end

  def self.performance_seconds_to_values(result_id, labels, cut_percent)
    data = {}
    labels.each do |label|
      data[label] = {seconds: [], values: []}
      bottom_timestamp, top_timestamp = border_timestamps(result_id, PerformanceResult, cut_percent)
      records = PerformanceResult.where(where_conditional(result_id, label, bottom_timestamp, top_timestamp))
      timestamp_min = records.minimum(:timestamp)
      records.order(:timestamp).each do |record|
        data[label][:seconds].push (record.timestamp - timestamp_min) / 1000
        data[label][:values].push record.value
      end
    end
    data
  end

  private

  def self.update_requests(result, requests_data, previous_time_cut_percent)
    if requests_data.present?
      result.requests_data = requests_data
      validate_requests_data(result)
      return if result.errors.any?
      result.save
      result.requests_results.delete_all
      save_request_data(result)
      calc_request_data(result)
    else
      if previous_time_cut_percent != result.time_cutting_percent && result.errors.empty?
        calc_request_data(result)
      end
    end
  end

  def self.update_performance(result, performance_data, previous_time_cut_percent)
    if performance_data.present?
      result.performance_data = performance_data
      validate_performance_data(result)
      return if result.errors.any?
      result.save
      result.performance_data.delete_all
      save_performance_data(result)
      calc_performance_data(result)
    else
      if previous_time_cut_percent != result.time_cutting_percent && result.performance_results.present? && result.errors.empty?
        calc_performance_data(result)
      end
    end
  end

  def self.calc_request_data(result)
    bottom_timestamp, top_timestamp = border_timestamps(result.id, RequestsResult, result.time_cutting_percent)
    labels = RequestsResult.where(result_id: result.id).pluck(:label).uniq
    labels.each do |label|
      calculated_request_result = CalculatedRequestsResult.find_or_create_by(result_id: result.id, label: label)
      records = RequestsResult.where(where_conditional(result.id, label, bottom_timestamp, top_timestamp))
      unless records.empty?
        data = records.pluck(:value)
        data = result.value_smoothing_interval.present? ? Statistics.simple_moving_average(data, result.value_smoothing_interval) : data
        calculated_request_result.update_attributes!(
            mean: Statistics.average(data).round(2),
            median: Statistics.median(data).round(2),
            ninety_percentile: Statistics.percentile(data, 90).round(2),
            max: data.max,
            min: data.min,
            throughput: RequestsUtils.throughput(data, bottom_timestamp, top_timestamp).round(2),
            failed_results: RequestsUtils.failed_requests(records.pluck(:response_code), bottom_timestamp, top_timestamp).round(2)
        )
      end
    end
  end

  def self.calc_performance_data(result)
    bottom_timestamp, top_timestamp = border_timestamps(result.id, PerformanceResult, result.time_cutting_percent)
    labels = PerformanceResult.where(result_id: result.id).pluck(:label).uniq
    labels.each do |label|
      calculated_performance_result = CalculatedPerformanceResult.find_or_create_by(result_id: result.id, label: label)
      records = PerformanceResult.where(where_conditional(result.id, label, bottom_timestamp, top_timestamp))
      if records
        data = records.pluck(:value)
        data = result.value_smoothing_interval.present? ? Statistics.simple_moving_average(data, result.value_smoothing_interval) : data
        calculated_performance_result.update_attributes!(
            mean: Statistics.average(data).round(2),
            max: data.max,
            min: data.min
        )
      end
    end
  end

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

  def self.validate_requests_data(result)
    header = File.open(result.requests_data.current_path) { |f| f.readline }
    validate_header(result, header, 'request', %w(timeStamp label responseCode Latency))
  end

  def self.validate_performance_data(result)
    header = File.open(result.performance_data.current_path) { |f| f.readline }
    validate_header(result, header, 'performance', %w(timeStamp label elapsed))
  end

  def self.validate_header(result, header, data_type, required_fields)
    required_fields.each do |column_name|
      result.errors.add(:base, "#{column_name} column in #{data_type} data is required!") unless header.include?(column_name)
    end
  end

  def self.save_request_data(result)
    validate_requests_data(result)
    return if result.errors.any?
    request_data = CSV.new(File.read(result.requests_data.current_path))
    header = request_data.first
    requests_results = request_data.map do |line|
      "(#{result.id}, #{line[header.index('timeStamp')]},
       '#{line[header.index('label')]}', '#{line[header.index('responseCode')]}',
       #{line[header.index('Latency')]}, '#{Time.now}', '#{Time.now}')"
    end
    ActiveRecord::Base.connection.execute(%(INSERT INTO requests_results (result_id, timestamp, label, response_code, value, created_at, updated_at)
                                            VALUES #{requests_results.join(', ')}))
    result
  end

  def self.save_performance_data(result)
    validate_performance_data(result)
    return if result.errors.any?
    performance_data = CSV.new(File.read(result.performance_data.current_path))
    header = performance_data.first
    performance_results = performance_data.map do |line|
      "(#{result.id}, #{line[header.index('timeStamp')]},
      '#{line[header.index('label')]}', #{line[header.index('elapsed')].to_i / 1000},
       '#{Time.now}', '#{Time.now}')"
    end
    ActiveRecord::Base.connection.execute(%(INSERT INTO performance_results (result_id, timestamp, label, value, created_at, updated_at)
                                            VALUES #{performance_results.join(', ')}))
    result
  end


end
