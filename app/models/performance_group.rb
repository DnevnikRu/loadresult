class PerformanceGroup < ActiveRecord::Base
  has_many :labels, class_name: 'PerformanceLabel'

end