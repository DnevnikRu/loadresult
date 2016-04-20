module Statistics


  def self.simple_moving_average(data, interval)
    return data if interval == 0 || interval.nil?
    begin
      interval = Integer(interval)
    rescue
      return data
    end
    return data if interval >= data.count
    return data if interval.even?
    split_interval(data, interval).map { |data_interval| average(data_interval).round(2) }
  end

  def self.median(data)
    sorted_array = data.sort
    rank = data.length * 0.5
    exactly_divide_check = rank - rank.to_i
    if exactly_divide_check.eql? 0.0
      first = (sorted_array[rank - 1]).to_f
      second = (sorted_array[rank]).to_f
      (first + second) / 2
    else
      sorted_array[rank]
    end
  end

  def self.percentile(data_set, percent)
    return nil if data_set.empty?

    sorted_data = data_set.sort
    index = (percent.to_f / 100 * data_set.length) - 1
    return sorted_data.first if index < 0

    if index.to_s.split('.').last.to_i.zero? # whole number?
      sorted_data[index] # return an element of data_set
    else
      left = sorted_data[index.floor]
      right = sorted_data[index.ceil]
      (left + right) / 2.0 # return average
    end
  end

  def self.average(data)
    data.inject(:+) / data.count.to_f
  end

  private

  def self.split_interval(data, interval)
    result = []
    step = (interval - 1) / 2
    first_index = step
    last_index = data.count - step - 1
    (first_index..last_index).each do |i|
      result.push data[i-step..i+step]
    end
    result
  end


end