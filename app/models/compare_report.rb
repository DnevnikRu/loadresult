class CompareReport

  attr_reader :result1, :result2

  def initialize(request1, request2)
    @result1 = request1
    @result2 = request2
  end

  def description
    description = {}
    %w(version rps duration profile test_run_date time_cutting_percent).each do |key|
      values = {}
      values[:result1] = @result1.send(key)
      values[:result2] = @result2.send(key)
      description[key.gsub('_', ' ').capitalize] = values
    end
    description
  end

  def request_labels
    (@result1.calculated_requests_results.pluck(:label).uniq & @result2.calculated_requests_results.pluck(:label).uniq).sort
  end

  def performance?
    @result1.calculated_performance_results.any? && @result2.calculated_performance_results.any?
  end


  def performance_groups
    labels = @result1.calculated_performance_results.pluck(:label) & @result2.calculated_performance_results.pluck(:label)
    label_groups = []
    PerformanceGroup.all.each do |group|
      labels_in_group = labels.select { |label| !group.labels.pluck(:label).select{ |l| label.include? l }.empty? }
      unless labels_in_group.empty?
        label_groups.push({
                              name: group.name,
                              labels: labels_in_group,
                              trend_limit: group.trend_limit,
                              units: group.units
                          })
      end
    end
    label_groups
  end

  def trend(type, metric, label, limit=0)
    first = @result1.send(type).find_by(label: label).send(metric)
    second = @result2.send(type).find_by(label: label).send(metric)
    if ((first == 0.0 || first.nil?) && (second == 0.00 || second.nil?)) || ((first + second) / 2 < limit)
      0.00
    elsif first == 0.0 || first.nil?
       100.0
    else
      (((second - first) / first)*100).round(2)
    end
  end

end