class PerformanceGroup < ActiveRecord::Base
  has_many :labels, class_name: 'PerformanceLabel'


  def self.split_labels_by_group(labels)
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

end
