require 'spec_helper'
require 'statistics'

describe Statistics do
  include Statistics

  describe '.simple_moving_average' do

    it 'return same data if interval is 0' do
      expect(simple_moving_average([1, 2, 3], 0)).to match_array([1, 2, 3])
    end

    it 'return same data if interval is nil' do
      expect(simple_moving_average([1, 2, 3], nil)).to match_array([1, 2, 3])
    end

    it 'raise exception when interval not Integer' do
      interval = 'abc'
      expect {simple_moving_average([1,2,3], interval)}.to raise_error(ArgumentError, %{invalid value for Integer(): "#{interval}"})
    end

    it 'raise exception when interval more than data size' do
      data = [1,2,3]
      interval = 4
      expect {simple_moving_average(data, interval)}.to raise_error("#{interval} >= #{data.count}! Interval can not be more or equal data size")
    end

    it 'interval can not be even' do
      expect {simple_moving_average([1,2,3], 2)}.to raise_error('Interval can not be even!')
    end

    it 'data with emissions after smooth is correct' do
      actual_data = [1, 4, 15, 2, 3, 20, 3]
      expect_data = [6.67, 6.67, 7.0, 8.33, 8.67]
      expect(simple_moving_average(actual_data,3)).to match_array(expect_data)
    end

  end

  describe '.split_interval'  do

    it 'number of intervals correct' do
      actual_data = Array.new(7,1)
      interval = 3
      expect(split_interval(actual_data, interval).count).to eql(actual_data.count - interval + 1)
    end

    it 'array splitted on intervals correct' do
      actual_data = [1, 4, 15, 2, 3, 20, 3]
      expect_data = [[1,4,15],[4,15,2],[15,2,3],[2,3,20],[3,20,3]]
      expect(split_interval(actual_data, 3)).to match_array(expect_data)
    end

  end
end