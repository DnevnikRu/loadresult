class RequestsResult < ActiveRecord::Base
  belongs_to :result

  def self.values_order_by_timestamp(where_clause)
    query = "SELECT requests_results.value FROM requests_results WHERE #{where_clause} ORDER BY timestamp"
    ActiveRecord::Base.connection.execute(query).field_values('value').map(&:to_f)
  end

  def self.max_min_timestamps(where_clause)
    query = "SELECT max(timestamp) as max_t, min(timestamp) as min_t FROM requests_results WHERE #{where_clause}"
    result = ActiveRecord::Base.connection.execute(query)
    { max: result[0]['max_t'].to_i, min: result.first['min_t'].to_i }
  end


end
