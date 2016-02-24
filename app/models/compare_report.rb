class CompareReport

  PERFORMANCE_GROUPS = YAML.load_file(Rails.root.join('config/performance_groups.yml'))

  attr_reader :result1, :result2

  def initialize(request1, request2)
    @result1 = request1
    @result2 = request2
  end

  def description
    description = {}
    %w(version rps duration profile test_run_date).each do |key|
      values = {}
      values[:result1] = @result1.send(key)
      values[:result2] = @result2.send(key)
      description[key.gsub('_', ' ').capitalize] = values
    end
    description
  end

  def request_labels
    @result1.requests_results.pluck(:label) | @result2.requests_results.pluck(:label)
  end

  def performance?
    @result1.performance_results.any? && @result2.performance_results.any?
  end


  def performance_groups
    labels = @result1.performance_results.pluck(:label) | @result2.performance_results.pluck(:label)
    label_groups = []
    PERFORMANCE_GROUPS.each do |group|
      labels_in_group = labels.select { |label| !group['labels'].select { |l| label.include? l }.empty? }
      unless labels_in_group.empty?
        label_groups.push({
                              name: group['name'],
                              labels: labels_in_group,
                              trend_limit: group['trend_limit'],
                              units: group['units']
                          })
      end
    end
    label_groups
  end

  def trend(metric, label, limit=0)
    first = @result1.send(metric, label).to_f
    second = @result2.send(metric, label).to_f
    if((first + second) / 2 < limit)
      0.00
    else
      (((second - first) / first)*100).round(2)
    end
  end

end