class CompareReport
  include ArrayUtils
  attr_reader :result1, :result2

  def initialize(request1, request2)
    @result1 = request1
    @result2 = request2
  end

  def description
    description = {}
    %w(version rps duration profile test_run_date time_cutting_percent).each do |key|
      values = {}
      values[:result1] = result1.send(key)
      values[:result2] = result2.send(key)
      description[key.humanize] = values
    end
    description
  end

  def request_labels
    (result1.calculated_requests_results.pluck(:label).uniq & result2.calculated_requests_results.pluck(:label).uniq).sort
  end

  def performance?
    result1.calculated_performance_results.any? && result2.calculated_performance_results.any?
  end

  def performance_groups
    labels = result1.calculated_performance_results.pluck(:label) & result2.calculated_performance_results.pluck(:label)
    label_groups = []
    PerformanceGroup.find_each do |group|
      labels_in_group = labels.select { |label| !group.labels.pluck(:label).select { |l| label.include? l }.empty? }
      next if labels_in_group.empty?
      label_groups.push(name: group.name,
                        labels: labels_in_group,
                        trend_limit: group.trend_limit,
                        units: group.units)
    end
    label_groups
  end

  def trend(type, metric, label, limit = 0)
    first = result1.send(type).find_by(label: label).send(metric)
    second = result2.send(type).find_by(label: label).send(metric)
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

  def differences
    diff = []
    diff += description_differences
    diff += label_differences
    diff
  end

  private

  def description_differences
    diff = []
    template = "%s: id:%d has '%s' but id:%d has '%s'"
    description_to_check = {
      duration: 'Duration',
      rps: 'Rps',
      profile: 'Profile',
      time_cutting_percent: 'Time cutting percent'
    }
    description_to_check.each do |field, field_name|
      result1_value = result1.send(field)
      result2_value = result2.send(field)
      if result1_value != result2_value
        diff.push template % [field_name, result1.id, result1_value, result2.id, result2_value]
      end
    end
    diff
  end

  def label_differences
    diff = []
    template = 'id:%d has extra %s labels: %s'
    result1_perf_labels = result1.calculated_performance_results.pluck(:label).uniq
    result2_perf_labels = result2.calculated_performance_results.pluck(:label).uniq
    result1_request_labels = result1.calculated_requests_results.pluck(:label).uniq
    result2_request_labels = result2.calculated_requests_results.pluck(:label).uniq
    result1_extra_perf_labels = result1_perf_labels - result2_perf_labels
    result2_extra_perf_labels = result2_perf_labels - result1_perf_labels
    result1_extra_request_labels = result1_request_labels - result2_request_labels
    result2_extra_request_labels = result2_request_labels - result1_request_labels
    if result1_extra_perf_labels.any?
      diff.push template % [result1.id, 'performance', join_with_quotes(result1_extra_perf_labels)]
    end
    if result2_extra_perf_labels.any?
      diff.push template % [result2.id, 'performance', join_with_quotes(result2_extra_perf_labels)]
    end
    if result1_extra_request_labels.any?
      diff.push template % [result1.id, 'request', join_with_quotes(result1_extra_request_labels)]
    end
    if result2_extra_request_labels.any?
      diff.push template % [result2.id, 'request', join_with_quotes(result2_extra_request_labels)]
    end
    diff
  end
end
