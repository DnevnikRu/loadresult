require 'rails_helper'

describe CompareReport do

  before(:all) do
    result1 = create(:result)
    result2 = create(:result, version: 'master-2', test_run_date: '01.01.2016 00:00')
    @compare_report = CompareReport.new(result1, result2)
  end

  describe '#description' do
    before(:all) do
      @description = @compare_report.description
    end


    it 'is a Hash' do
       expect(@description).to be_a(Hash)
    end

    it 'has all keys' do
      keys = ['Duration', 'Profile', 'Rps', 'Test run date', 'Version']
      expect(@description.keys).to match_array(keys)
    end

    it 'each keys has two value: result1 and result2' do
      actual = @description.values.map{|v| v.is_a?(Hash) && !v[:result1].nil? && !v[:result2].nil?}
      expect(actual.reduce(:&)).to be(true), "Expect that description values is a Hash and contains two keys for result1 and result2b but actual: #{@description.values}"
    end



  end

end