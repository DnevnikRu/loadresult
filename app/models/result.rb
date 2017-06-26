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
  validate :release_date_is_date_or_blank

  mount_uploader :requests_data, ResultUploader
  mount_uploader :performance_data, ResultUploader

  filterrific(
      default_filter_params: {sorted_by: 'test_run_date_desc'},
      available_filters: [
          :sorted_by,
          :version_search_query,
          :with_project_id,
          :release_date_gte,
          :release_date_lt,
          :test_run_date_gte,
          :test_run_date_lt
      ]
  )

  scope :version_search_query, lambda { |query|
    return if query.blank?
    terms = query.to_s.downcase.split(/\s+/)
    terms = terms.map { |e|
      ('%' + e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }
    where(
        terms.map { |term|
          "(LOWER(results.version) LIKE ? )"
        }.join(' AND '),
        *terms.map { |e| [e] }.flatten
    )
  }

  scope :sorted_by, lambda { |sort_option|
    if sort_option =~ /desc$/
      direction = 'desc'
      nulls_pos = 'LAST'
    else
      direction = 'asc'
      nulls_pos = 'FIRST'
    end
    case sort_option.to_s
      when /^test_run_date_/
        order("results.test_run_date #{ direction }")
      when /^version_/
        order("LOWER(results.version) #{ direction }")
      when /^release_date_/
        order("results.release_date #{ direction } NULLS #{nulls_pos}")
      when /^id_/
        order("results.id #{ direction }")
      when /^project_/
        joins(:project).order("projects.project_name #{ direction }, results.project_id #{ direction }" )
      when /^rps_/
        order("results.rps #{ direction }")
      when /^duration_/
        order("results.duration #{ direction }")
      when /^profile_/
        order("LOWER(results.profile) #{ direction }")
      when /^data_version_/
        order("case when results.data_version IS NULL or results.data_version = '' THEN 1
                    ELSE 2
                    end #{ direction }, results.data_version #{ direction } ")
      when /^time_cutting_percent_/
        order("results.time_cutting_percent #{ direction }")
      when /^smoothing_percent_/
        order("results.smoothing_percent #{ direction }")
      when /^comment_/
        order("case when results.comment IS NULL or results.comment = '' THEN 1
                    ELSE 2
                    end #{ direction }, results.comment #{ direction } ")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_project_id, lambda { |project_id|
    where(projects: {id: project_id}).joins(:project)
  }

  scope :release_date_gte, lambda { |reference_time|
    where('results.release_date >= ?', DateTime.parse(reference_time))
  }

  scope :release_date_lt, lambda { |reference_time|
    where('results.release_date < ?', DateTime.parse(reference_time))
  }

  scope :test_run_date_gte, lambda { |reference_time|
    where('results.test_run_date >= ?', DateTime.parse(reference_time))
  }

  scope :test_run_date_lt, lambda { |reference_time|
    where('results.test_run_date < ?', DateTime.parse(reference_time))
  }

  def test_run_date_is_datetime
    errors.add(:test_run_date, 'must be in a datetime format') if test_run_date.nil?
  end

  def release_date_is_date_or_blank
    if read_attribute_before_type_cast('release_date').present?
      errors.add(:release_date, 'must be a valid datetime') if ((DateTime.parse(release_date.to_s) rescue ArgumentError) == ArgumentError)
    end
  end

  def self.upload_and_create(params)
    result = Result.new(
        project_id: params['project'],
        version: params['version'],
        duration: params['duration'],
        rps: params['rps'],
        profile: params['profile'],
        data_version: params['data_version'],
        test_run_date: params['test_run_date'],
        requests_data: params['requests_data'].is_a?(Hash) ? file_from_json(params, 'requests_data') : params['requests_data'],
        performance_data: params['performance_data'].is_a?(Hash) ? file_from_json(params, 'performance_data') : params['performance_data'],
        time_cutting_percent: params['time_cutting_percent'].blank? ? 0 : params['time_cutting_percent'],
        smoothing_percent: params['smoothing_percent'].blank? ? 0 : params['smoothing_percent'],
        release_date: params['release_date']
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
    previous_smooth_percent = result.smoothing_percent
    result.update(
        project_id: params[:project],
        version: params[:version],
        rps: params[:rps],
        duration: params[:duration],
        profile: params[:profile],
        data_version: params[:data_version],
        test_run_date: params[:test_run_date],
        time_cutting_percent: params[:time_cutting_percent].blank? ? 0 : params[:time_cutting_percent],
        smoothing_percent: params[:smoothing_percent].blank? ? 0 : params[:smoothing_percent],
        comment: params[:comment],
        requests_data: params[:requests_data],
        performance_data: params[:performance_data],
        release_date: params[:release_date]
    )

    update_requests(result, params[:requests_data], previous_time_cut_percent, previous_smooth_percent)
    update_performance(result, params[:performance_data], previous_time_cut_percent, previous_smooth_percent)

    result
  end

  def self.border_timestamps(id, table, cut_percent)
    results = table.where(result_id: id)
    min_timestamp = results.minimum(:timestamp)
    max_timestamp = results.maximum(:timestamp)
    cut_timestamp(min_timestamp, max_timestamp, cut_percent)
  end

  def self.cut_timestamp(min, max, cut_percent)
    cut_percent = cut_percent.to_f / 100
    cutted_time = (max - min) * cut_percent
    [(min + cutted_time.to_i), (max - cutted_time.to_i)]
  end

  def self.where_conditional(id = nil, label = nil, bottom_timestamp = nil, top_timestamp = nil)
    where_request = []
    where_request.push "result_id = #{id}" if id
    where_request.push "label = '#{label}'" if label
    where_request.push "timestamp >= #{bottom_timestamp}" if bottom_timestamp
    where_request.push "timestamp <= #{top_timestamp}" if top_timestamp
    where_request.size > 1 ? where_request.join(' AND ') : where_request.join
  end

  def self.values_of_requests(result_id, label = nil, cut_percent)
    result = Result.find_by(id: result_id)

    records = RequestsResult.where(where_conditional(result_id, label)).order(:timestamp).to_a
    timestamp_min, timestamp_max = cut_timestamp(records.first.timestamp, records.last.timestamp, cut_percent)
    records = records.select { |record| record.timestamp >= timestamp_min && record.timestamp <= timestamp_max }
    values = records.map { |record| record.value }

    if result.smoothing_percent.to_i != 0
      interval = Statistics.sma_interval(values, result.smoothing_percent)
      Statistics.simple_moving_average(values, interval)
    else
      values
    end
  end

  def self.percentile_of_values_of_requests(result_id, cut_percent)
    values = values_of_requests(result_id, cut_percent)
    (1..100).map { |i| Statistics.percentile(values, i) }
  end

  def self.requests_seconds_to_values(result_id, label, cut_percent)
    result = Result.find_by(id: result_id)
    data = {seconds: [], values: []}

    records = RequestsResult.where(where_conditional(result_id, label)).order(:timestamp).to_a
    timestamp_min, timestamp_max = cut_timestamp(records.first.timestamp, records.last.timestamp, cut_percent)
    records = records.select { |record| record.timestamp >= timestamp_min && record.timestamp <= timestamp_max }
    data[:seconds] = records.map { |record| (record.timestamp - timestamp_min) / 1000 }

    values = records.map { |record| record.value }
    data[:values] = if result.smoothing_percent.to_i != 0
                      interval = Statistics.sma_interval(values, result.smoothing_percent)
                      Statistics.simple_moving_average(values, interval)
                    else
                      values
                    end
    data
  end

  def self.performance_seconds_to_values(result_id, labels, cut_percent)
    data = {}
    labels.each do |label|
      data[label] = {seconds: [], values: []}
      bottom_timestamp, top_timestamp = border_timestamps(result_id, PerformanceResult, cut_percent)
      records = PerformanceResult.where(where_conditional(result_id, nil, bottom_timestamp, top_timestamp))
      timestamp_min = records.minimum(:timestamp)
      records = records.where(label: label).order(:timestamp)
      result = Result.find_by(id: result_id)
      data[label][:seconds] = records.pluck(:timestamp, :value).map { |record| ((record[0] - timestamp_min) / 1000) - record[1] }.sort
      data[label][:values] = if result.smoothing_percent.to_i != 0
                               interval = Statistics.sma_interval(records.pluck(:value), result.smoothing_percent)
                               Statistics.simple_moving_average(records.pluck(:value), interval)
                             else
                               records.pluck(:value)
                             end
    end
    data
  end

  def description
    description = {}
    %w(version rps duration profile data_version test_run_date time_cutting_percent smoothing_percent).each do |key|
      description[key.humanize] = self.send(key)
    end
    description
  end

  def performance_groups
    labels = self.calculated_performance_results.pluck(:label)
    label_groups = []
    PerformanceGroup.find_each do |group|
      labels_in_group = labels.select { |label| !group.labels.pluck(:label).select { |l| label.include? l }.empty? }
      next if labels_in_group.empty?
      label_groups.push(name: group.name,
                        labels: labels_in_group,
                        units: group.units)
    end
    label_groups
  end

  def request_labels_uniq
    calculated_requests_results.where.not(label: 'all_requests').pluck(:label).uniq
  end

  private

  def self.update_requests(result, requests_data, previous_time_cut_percent, previous_smooth_percent)
    if requests_data.present?
      result.requests_data = requests_data
      validate_requests_data(result)
      return if result.errors.any?
      result.save
      result.requests_results.delete_all
      save_request_data(result)
      calc_request_data(result)
    else
      if result.errors.empty? &&
          (previous_time_cut_percent != result.time_cutting_percent ||
              previous_smooth_percent != result.smoothing_percent)
        calc_request_data(result)
      end
    end
  end

  def self.update_performance(result, performance_data, previous_time_cut_percent, previous_smooth_percent)
    if performance_data.present?
      result.performance_data = performance_data
      validate_performance_data(result)
      return if result.errors.any?
      result.save
      result.performance_data.delete_all
      save_performance_data(result)
      calc_performance_data(result)
    else
      if result.errors.empty? &&
          result.performance_results.present? &&
          (previous_time_cut_percent != result.time_cutting_percent ||
              previous_smooth_percent != result.smoothing_percent)
        calc_performance_data(result)
      end
    end
  end

  def self.calc_request_data(result)
    bottom_timestamp, top_timestamp = border_timestamps(result.id, RequestsResult, result.time_cutting_percent)
    calc_request_data_by_label(result, bottom_timestamp, top_timestamp)
    calc_all_request_data(result, bottom_timestamp, top_timestamp)
  end

  def self.calc_request_data_by_label(result, bottom_timestamp, top_timestamp)
    labels = RequestsResult.where(result_id: result.id).pluck(:label).uniq
    labels.each do |label|
      calculated_request_result = CalculatedRequestsResult.find_or_create_by(result_id: result.id, label: label)
      records = RequestsResult.where(where_conditional(result.id, label, bottom_timestamp, top_timestamp))
      unless records.empty?
        data = records.pluck(:value)
        data = Statistics.simple_moving_average(data, Statistics.sma_interval(data, result.smoothing_percent)) if result.smoothing_percent.to_i != 0
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

  def self.calc_all_request_data(result, bottom_timestamp, top_timestamp)
    values = Result.values_of_requests(result.id, nil, result.time_cutting_percent)
    calculated_request_result = CalculatedRequestsResult.find_or_create_by(result_id: result.id, label: 'all_requests')
    calculated_request_result.update_attributes!(
        mean: Statistics.average(values),
        median: Statistics.median(values),
        ninety_percentile: Statistics.percentile(values, 90),
        throughput: RequestsUtils.throughput(values, bottom_timestamp, top_timestamp)
    )
  end

  def self.calc_performance_data(result)
    bottom_timestamp, top_timestamp = border_timestamps(result.id, PerformanceResult, result.time_cutting_percent)
    labels = PerformanceResult.where(result_id: result.id).pluck(:label).uniq
    labels.each do |label|
      calculated_performance_result = CalculatedPerformanceResult.find_or_create_by(result_id: result.id, label: label)
      records = PerformanceResult.where(where_conditional(result.id, label, bottom_timestamp, top_timestamp))
      if records
        data = records.pluck(:value)
        data = Statistics.simple_moving_average(data, Statistics.sma_interval(data, result.smoothing_percent)) if result.smoothing_percent != 0
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
