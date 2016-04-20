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

    it 'return data without smoothing when interval not Integer' do
      interval = 'abc'
      data  = [1,2,3]
      expect(Statistics.simple_moving_average(data, interval)).to match_array(data)
    end

    it 'return data without smoothing when interval more than data size' do
      data = [1,2,3]
      interval = 4
      expect(Statistics.simple_moving_average(data, interval)).to match_array(data)
    end

    it 'return data without smoothing if interval even' do
      data = [1,2,3]
      expect(Statistics.simple_moving_average(data, 2)).to match_array(data)
    end

    it 'data with emissions after smooth is correct' do
      actual_data = [1, 4, 15, 2, 3, 20, 3]
      expect_data = [6.67, 6.67, 7.0, 8.33, 8.67]
      expect(Statistics.simple_moving_average(actual_data,3)).to match_array(expect_data)
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
end
