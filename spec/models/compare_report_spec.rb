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
      keys = ['Duration', 'Profile', 'Rps', 'Test run date', 'Time cutting percent', 'Version', 'Value smoothing interval']
      expect(@description.keys).to match_array(keys)
    end

    it 'each keys except Value smoothing interval has two value: result1 and result2' do
      description = @description.dup
      description.delete('Value smoothing interval')
      actual = description.values.map { |v| v.is_a?(Hash) && !v[:result1].nil? && !v[:result2].nil? }
      expect(actual.reduce(:&)).to be(true), "Expect that description values is a Hash and contains two keys for result1 and result2b but actual: #{description.values}"
    end
  end

  describe '#performance_label_groups' do
    before(:all) do
      result = create(:result)
      ['db07 EXEC Network\Bytes Sent/sec', 'db07 EXEC Network\Bytes Received/sec', 'db08 CPU Processor Time',
       'web00 CPU Processor Time', 'web00 EXEC Disk(inst_1)\Avg. Read Queue'].each do |label|
        create(:calculated_performance_result, result_id: result.id, label: label)
      end
      compare_report = CompareReport.new(result, result)
      @performance_label_groups = compare_report.performance_groups
      @exp_performance_label_groups = [
          {
              name: 'Network traffic',
              units: 'Mb/sec',
              trend_limit: 100,
              labels: ['db07 EXEC Network\Bytes Sent/sec', 'db07 EXEC Network\Bytes Received/sec']
          },
          {
              name: 'Processor',
              units: '%',
              trend_limit: 0,
              labels: ['db08 CPU Processor Time', 'web00 CPU Processor Time']
          },
          {
              name: 'Disk queue',
              units: 'unit',
              trend_limit: 0.5,
              labels: ['web00 EXEC Disk(inst_1)\Avg. Read Queue']
          }
      ]
    end

    it 'contains all group' do
      expect(@performance_label_groups.map{|g| g[:name]}).to match_array(@exp_performance_label_groups.map{|g| g[:name]})
    end

    it 'disk group is correct' do
      label = 'Disk queue'
      expect(@performance_label_groups.select{|g| g[label]}).to match_array(@exp_performance_label_groups.select{|g| g[label]})
    end

    it 'processor group is correct' do
      label = 'Processor'
      expect(@performance_label_groups.select{|g| g[label]}).to match_array(@exp_performance_label_groups.select{|g| g[label]})
    end

    it 'network group is correct' do
      label = 'Network traffic'
      expect(@performance_label_groups.select{|g| g[label]}).to match_array(@exp_performance_label_groups.select{|g| g[label]})
    end

  end

  describe '#trend' do

    it 'positive trend' do
      result1 = create(:result)
      result2 = create(:result)
      compare_report = CompareReport.new(result1, result2)

      create(:calculated_requests_result, label: 'test', mean: 250, result_id: compare_report.result1.id)
      create(:calculated_requests_result, label: 'test', mean: 300, result_id: compare_report.result2.id)

      expect(compare_report.trend(:calculated_requests_results,:mean, 'test')).to eql 20.0
    end

    it 'negative trend' do
      result1 = create(:result)
      result2 = create(:result)
      compare_report = CompareReport.new(result1, result2)

      create(:calculated_requests_result, label: 'test', mean: 300, result_id: compare_report.result1.id)
      create(:calculated_requests_result, label: 'test', mean: 250, result_id: compare_report.result2.id)

      expect(compare_report.trend(:calculated_requests_results, :mean, 'test')).to eq -16.67
    end

  end

end
