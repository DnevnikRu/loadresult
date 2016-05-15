class TrendReport
  attr_reader :results, :error

  def initialize(result1, result2)
    result1 = Result.find_by(id: result1)
    result2 = Result.find_by(id: result2)

    if result1.nil? || result2.nil?
      @error = "Can't find selected results"
      return
    end

    if result1.project_id != result2.project_id
      @error = "Can't create a trend with results in different projects"
      return
    end

    if result1.release_date.nil? || result2.release_date.nil?
      @error = "Can't create a trend with results without release date"
      return
    end

    result_from, result_to = [result1, result2].sort_by(&:release_date)
    results_between = Result.where(
      release_date: (result_from.release_date..result_to.release_date),
      project_id: result1.project_id
    )
    if results_between.size == 2
      @error = "There are only 2 results between selected results. Can't create a trend"
      return
    end

    @results = results_between.sort_by(&:release_date)
  end

  def description_differences
    diff = []
    results.each do |result|
      if diff.empty? ||
        diff.last[:duration] != result.duration ||
        diff.last[:rps] != result.rps ||
        diff.last[:profile] != result.profile ||
        diff.last[:time_cutting_percent] != result.time_cutting_percent ||
        diff.last[:value_smoothing_interval] != result.value_smoothing_interval
        diff.push(
          ids: [result.id],
          duration: result.duration,
          rps: result.rps,
          profile: result.profile,
          time_cutting_percent: result.time_cutting_percent,
          value_smoothing_interval: result.value_smoothing_interval
        )
      else
        diff.last[:ids].push result.id
      end
    end
    diff
  end

  def sorted_labels_by_mean_trend
    request_labels.map do |label|
      percent = trend_in_trend(:calculated_requests_results, :mean, label)
      [label, percent]
    end.sort_by { |arr| arr[1] }.reverse
  end

  def performance_groups
    labels = perfromance_labels
    PerformanceGroup.split_labels_by_group(labels)
  end

  def request_labels
    results.inject([]) do |labels, result|
      result.calculated_requests_results.pluck(:label).uniq | labels
    end
  end

  def perfromance_labels
    results.inject([]) do |labels, result|
      result.calculated_performance_results.pluck(:label).uniq | labels
    end
  end

  def ids_with_date
    ids.map { |id| "id:#{id} #{Result.find_by(id: id).release_date.to_date}" }
  end

  def request_data(label)
    data = {}
    attributes = [:mean, :median, :ninety_percentile, :throughput]
    attributes.each { |at| data[at] = [] }
    ids.each do |id|
      calc_result = CalculatedRequestsResult.find_by(result_id: id, label: label)
      attributes.each do |at|
        value = calc_result ? calc_result.send(at) : 0 # if a result doesn't have the label just show 0
        data[at].push value
      end
    end
    data
  end

  def all_requests_data
    data = {}
    attributes = [:mean, :median, :ninety_percentile, :throughput]
    attributes.each { |at| data[at] = [] }
    ids.each do |id|
      values = Result.values_of_requests(id, nil, @results.find{|e| e.id = id}.time_cutting_percent)
      data[:mean].push Statistics.average(values)
      data[:median].push Statistics.median(values)
      data[:ninety_percentile].push Statistics.percentile(values, 90)
      start_time, end_time = Result.border_timestamps(id, RequestsResult, @results.find{|e| e.id = id}.time_cutting_percent)
      data[:throughput].push RequestsUtils.throughput(values, start_time, end_time)
    end
    data
  end

  def ids
    @ids ||= results.map(&:id)
    @ids
  end

  def trend_in_trend(type, metric, label, limit = 0)
    first = results.first.send(type).find_by(label: label).send(metric)
    second = results.last.send(type).find_by(label: label).send(metric)
    first = 0.0 if first.nil?
    second = 0.0 if second.nil?
    if (first == 0.0 && second == 0.00) || ((first + second) / 2 < limit)
      0.00
    elsif first == 0.0 || first.nil?
      100.0
    else
      (((second - first) / first) * 100).round(2)
    end
  end

end
