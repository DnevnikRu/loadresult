class PerformanceGroup < ActiveRecord::Base
  has_many :labels, class_name: 'PerformanceLabel', dependent: :delete_all

  validates :name, presence: true
  validates :units, presence: true
  validates :trend_limit, presence: true


  def self.create_new_group(params)
    group = PerformanceGroup.new(
        name: params['name'],
        units: params['units'],
        trend_limit: params['trend_limit'],
        metrics_type: params['metrics_type']
    )
    group.save
    group
  end

  def self.edit_group(group, params)
    group.update(
        name: params[:name],
        units: params[:units],
        trend_limit: params[:trend_limit],
        metrics_type: params[:metrics_type]
    )
    group
  end

  def self.split_labels_by_group(labels)
    label_groups = []
    PerformanceGroup.find_each do |group|
      labels_in_group = labels.select {|label| !group.labels.pluck(:label).select {|l| label.include? l}.empty?}
      next if labels_in_group.empty?
      label_groups.push(name: group.name,
                        labels: labels_in_group,
                        trend_limit: group.trend_limit,
                        units: group.units,
                        metrics_type: group.metrics_type
      )
    end
    label_groups
  end

end
