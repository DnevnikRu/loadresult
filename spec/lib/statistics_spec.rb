require 'spec_helper'
require 'statistics'

describe Statistics do

  describe '.simple_moving_average' do

    it 'return same data if interval is 0' do
      expect(Statistics.simple_moving_average([1, 2, 3], 0)).to match_array([1, 2, 3])
    end

    it 'return same data if interval is nil' do
      expect(Statistics.simple_moving_average([1, 2, 3], nil)).to match_array([1, 2, 3])
    end

    it 'raise exception when interval not Integer' do
      interval = 'abc'
      expect {Statistics.simple_moving_average([1,2,3], interval)}.to raise_error(ArgumentError, %{invalid value for Integer(): "#{interval}"})
    end

    it 'raise exception when interval more than data size' do
      data = [1,2,3]
      interval = 4
      expect {Statistics.simple_moving_average(data, interval)}.to raise_error("#{interval} >= #{data.count}! Interval can not be more or equal data size")
    end

    it 'interval can not be even' do
      expect {Statistics.simple_moving_average([1,2,3], 2)}.to raise_error('Interval can not be even!')
    end

    it 'data with emissions after smooth is correct' do
      actual_data = [1, 4, 15, 2, 3, 20, 3] # after added items: [1, 1, 4, 15, 2, 3, 20, 3, 3]
      expect_data = [2.0, 6.67, 6.67, 7.0, 8.33, 8.67, 8.67]
      expect(Statistics.simple_moving_average(actual_data,3)).to match_array(expect_data)
    end

    it 'interval equal 1' do
      data = [1,2,3]
      interval = 1
      expect(Statistics.simple_moving_average(data, interval)).to match_array data
    end

  end

  describe '.percentile' do
    it 'finds percentile of an array' do
      expect(Statistics.percentile([1, 2, 3, 4], 50)).to eq(2)
    end

    it 'finds percentile of an unsorted array' do
      expect(Statistics.percentile([3, 1, 2, 4], 50)).to eq(2)
    end

    it 'find percentile of array with odd number of elements' do
      expect(Statistics.percentile([1, 2, 3, 4, 5], 50)).to eq(2.5)
    end
  end

  describe '.split_interval'  do

    it 'number of intervals correct' do
      actual_data = Array.new(7,1)
      interval = 3
      expect(Statistics.split_interval(actual_data, interval).count).to eql(actual_data.count - interval + 1)
    end

    it 'array splitted on intervals correct' do
      actual_data = [1, 4, 15, 2, 3, 20, 3]
      expect_data = [[1,4,15],[4,15,2],[15,2,3],[2,3,20],[3,20,3]]
      expect(Statistics.split_interval(actual_data, 3)).to match_array(expect_data)
    end

  end

  describe '.add_items' do
    it 'result data length is correct' do
      actual_data = [1,2,3,4]
      interval = 3
      expect(Statistics.add_items(actual_data, interval).count).to eql actual_data.count + (interval - 1)
    end

    it 'first added items is correct' do
      actual_data = [1,2,3,4,5,6,7]
      interval = 5
      first_actual_element = actual_data.first
      expected_array = Array.new((interval - 1)/2, first_actual_element)
      actual_array = Statistics.add_items(actual_data, interval).first((interval - 1)/2)
      expect(actual_array).to match_array(expected_array)
    end

    it 'last added items is correct' do
      actual_data = [1,2,3,4,5,6,7]
      interval = 5
      last_actual_element = actual_data.last
      expected_array = Array.new((interval - 1)/2, last_actual_element)
      actual_array = Statistics.add_items(actual_data, interval).last((interval - 1)/2)
      expect(actual_array).to match_array(expected_array)
    end

  end

  describe '.sma_interval' do
    it '10 percent of data' do
      data = (0...100).to_a
      expect(Statistics.sma_interval(data, 10)).to eql 9
    end

    it 'small data and big percent' do
      data = (0...5).to_a
      expect(Statistics.sma_interval(data, 60)).to eql 3
    end

    it 'small data and small percent' do
      data = (0...5).to_a
      expect(Statistics.sma_interval(data, 10)).to eql 1
    end

    it '0 percent of data' do
      data = (0...100).to_a
      expect(Statistics.sma_interval(data, 0)).to eql 1
    end
  end
end
