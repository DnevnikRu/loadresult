class PerformanceResult < ActiveRecord::Base
  belongs_to :result

  def self.last_value(result, label)
    records = PerformanceResult.where(where_conditional(result.id, label))
    if records
      data = records.order(timestamp: :desc).limit(1).pluck(:value)
      data.empty? ? 0 : data[0]
    else
      0
    end
  end


end
