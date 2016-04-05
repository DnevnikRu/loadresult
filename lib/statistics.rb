module Statistics


  def simple_moving_average(data, interval)
    return data if interval == 0 || interval.nil?
    interval = Integer(interval)
    raise "#{interval} >= #{data.count}! Interval can not be more or equal data size" if interval >= data.count
    raise 'Interval can not be even!' if interval.even?
    split_interval(data, interval).map { |data_interval| average(data_interval).round(2) }
  end

  private

  def split_interval(data, interval)
    result = []
    step = (interval - 1) / 2
    first_index = step
    last_index = data.count - step - 1
    (first_index..last_index).each do |i|
      result.push data[i-step..i+step]
    end
    result
  end

  def average(data)
    data.inject(:+) / data.count.to_f
  end


end