module RequestsUtils

  def self.throughput(data, start_time, end_time)
    duration = (end_time - start_time)
    duration = (duration == 0 || duration / 1000.0 <= 1) ? 1 : duration / 1000.0
    (data.count.to_f / duration.to_f).round(2)
  end

  def self.failed_requests(responce_codes, bottom_timestamp, top_timestamp)
    unless responce_codes.empty?
      int_codes = responce_codes.map { |code| code.to_i }
      client_errors = int_codes.count { |code| code.between?(400, 499) }
      server_errors = int_codes.count { |code| code.between?(500, 599) }
      unrecognized_errors = int_codes.count { |code| code == 0 }
      failed_count = client_errors + server_errors + unrecognized_errors
      ((failed_count.to_f / int_codes.count) * 100).round(2)
    end
  end

end