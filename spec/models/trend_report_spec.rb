require 'rails_helper'

describe TrendReport do
  before { DatabaseCleaner.clean }

  describe '#description_differences' do
    context 'when meta data is similar' do
      before do
        @result1 = create(
          :result,
          duration: 600,
          rps: '150',
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3,
          release_date: '01.01.1978 00:01'
        )
        @result2 = create(
          :result,
          duration: 600,
          rps: '150',
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3,
          release_date: '01.01.1978 00:01'
        )
        @result3 = create(
          :result,
          duration: 600,
          rps: '150',
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3,
          release_date: '01.01.1978 00:02'
        )
        @trend_report = TrendReport.new(@result1, @result3)
      end

      it 'combines results' do
        expected_diff = [
          { ids: [@result1.id, @result2.id, @result3.id], duration: 600, rps: '150', profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 }
        ]
        expect(@trend_report.description_differences).to match(expected_diff)
      end
    end

    context 'when version and test run date is different' do
      before do
        @result1 = create(
          :result,
          version: 'master',
          test_run_date: '01.01.1978 00:00',
          duration: 600,
          rps: '150',
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @result2 = create(
          :result,
          version: 'master2',
          test_run_date: '02.02.1979 02:02',
          duration: 600,
          rps: '150',
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @result3 = create(
          :result,
          version: 'master3',
          test_run_date: '03.03.1979 03:03',
          duration: 600,
          rps: '150',
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @trend_report = TrendReport.new(@result1, @result3)
      end

      it 'still combines results' do
        expected_diff = [
          { ids: [@result1.id, @result2.id, @result3.id], duration: 600, rps: '150', profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 }
        ]
        expect(@trend_report.description_differences).to match(expected_diff)
      end
    end

    context 'when there is a difference in duration' do
      before do
        @result1 = create(
          :result,
          duration: 600,
          rps: '150',
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @result2 = create(
          :result,
          duration: 601,
          rps: '150',
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @result3 = create(
          :result,
          duration: 602,
          rps: '150',
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @trend_report = TrendReport.new(@result1, @result3)
      end

      it 'divides results' do
        expected_diff = [
          { ids: [@result1.id], duration: 600, rps: '150', profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 },
          { ids: [@result2.id], duration: 601, rps: '150', profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 },
          { ids: [@result3.id], duration: 602, rps: '150', profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 }
        ]
        expect(@trend_report.description_differences).to match(expected_diff)
      end
    end

    context 'when there is a difference in rps' do
      before do
        @result1 = create(
          :result,
          duration: 600,
          rps: '150',
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @result2 = create(
          :result,
          duration: 600,
          rps: '151',
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @result3 = create(
          :result,
          duration: 600,
          rps: '152',
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @trend_report = TrendReport.new(@result1, @result3)
      end

      it 'divides results' do
        expected_diff = [
          { ids: [@result1.id], duration: 600, rps: '150', profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 },
          { ids: [@result2.id], duration: 600, rps: '151', profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 },
          { ids: [@result3.id], duration: 600, rps: '152', profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 }
        ]
        expect(@trend_report.description_differences).to match(expected_diff)
      end
    end

    context 'when there is a difference in profile' do
      before do
        @result1 = create(
          :result,
          duration: 600,
          rps: '150',
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @result2 = create(
          :result,
          duration: 600,
          rps: '150',
          profile: 'all_site2',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @result3 = create(
          :result,
          duration: 600,
          rps: '150',
          profile: 'all_site3',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @trend_report = TrendReport.new(@result1, @result3)
      end

      it 'divides results' do
        expected_diff = [
          { ids: [@result1.id], duration: 600, rps: '150', profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 },
          { ids: [@result2.id], duration: 600, rps: '150', profile: 'all_site2', time_cutting_percent: 10, value_smoothing_interval: 3 },
          { ids: [@result3.id], duration: 600, rps: '150', profile: 'all_site3', time_cutting_percent: 10, value_smoothing_interval: 3 }
        ]
        expect(@trend_report.description_differences).to match(expected_diff)
      end
    end

    context 'when there is a difference in time_cutting_percent' do
      before do
        @result1 = create(
          :result,
          duration: 600,
          rps: '150',
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @result2 = create(
          :result,
          duration: 600,
          rps: '150',
          profile: 'all_site',
          time_cutting_percent: 11,
          value_smoothing_interval: 3
        )
        @result3 = create(
          :result,
          duration: 600,
          rps: '150',
          profile: 'all_site',
          time_cutting_percent: 12,
          value_smoothing_interval: 3
        )
        @trend_report = TrendReport.new(@result1, @result3)
      end

      it 'divides results' do
        expected_diff = [
          { ids: [@result1.id], duration: 600, rps: '150', profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 },
          { ids: [@result2.id], duration: 600, rps: '150', profile: 'all_site', time_cutting_percent: 11, value_smoothing_interval: 3 },
          { ids: [@result3.id], duration: 600, rps: '150', profile: 'all_site', time_cutting_percent: 12, value_smoothing_interval: 3 }
        ]
        expect(@trend_report.description_differences).to match(expected_diff)
      end
    end

    context 'when there is a difference in value_smoothing_interval' do
      before do
        @result1 = create(
          :result,
          duration: 600,
          rps: '150',
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @result2 = create(
          :result,
          duration: 600,
          rps: '150',
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 5
        )
        @result3 = create(
          :result,
          duration: 600,
          rps: '150',
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 7
        )
        @trend_report = TrendReport.new(@result1, @result3)
      end

      it 'divides results' do
        expected_diff = [
          { ids: [@result1.id], duration: 600, rps: '150', profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 },
          { ids: [@result2.id], duration: 600, rps: '150', profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 5 },
          { ids: [@result3.id], duration: 600, rps: '150', profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 7 }
        ]
        expect(@trend_report.description_differences).to match(expected_diff)
      end
    end
  end

  describe '#request_labels' do
    it 'returns uniq labels' do
      result1 = create(:result)
      create(:calculated_requests_result, result_id: result1.id, label: 'd')
      create(:calculated_requests_result, result_id: result1.id, label: 'c')
      result2 = create(:result)
      create(:calculated_requests_result, result_id: result2.id, label: 'c')
      create(:calculated_requests_result, result_id: result2.id, label: 'b')
      result3 = create(:result)
      create(:calculated_requests_result, result_id: result3.id, label: 'b')
      create(:calculated_requests_result, result_id: result3.id, label: 'a')

      trend_report = TrendReport.new(result1, result3)

      expect(trend_report.request_labels).to match_array(%w(a b c d))
    end
  end

  describe '#ids' do
    it 'returns ids of results' do
      result1 = create(:result)
      result2 = create(:result)
      result3 = create(:result)

      trend_report = TrendReport.new(result1, result3)

      expect(trend_report.ids).to match([result1.id, result2.id, result3.id])
    end
  end

  describe '#ids_with_date' do
    it 'returns ids with release dates' do
      result1 = create(:result, release_date: '01.01.1978 00:01')
      result2 = create(:result, release_date: '02.02.1979 00:02')
      result3 = create(:result, release_date: '03.03.1980 00:03')

      trend_report = TrendReport.new(result1, result3)

      expected_array = [
        "id:#{result1.id} 1978-01-01",
        "id:#{result2.id} 1979-02-02",
        "id:#{result3.id} 1980-03-03"
      ]
      expect(trend_report.ids_with_date).to match(expected_array)
    end
  end

  describe '#request_data' do
    it 'returns attributes with their values' do
      label = 'GET TEST'
      result1 = create(:result)
      result2 = create(:result)
      result3 = create(:result)
      create(
        :calculated_requests_result,
        result_id: result1.id,
        label: label,
        mean: 10,
        median: 20,
        ninety_percentile: 30,
        throughput: 40
      )
      create(
        :calculated_requests_result,
        result_id: result2.id,
        label: label,
        mean: 100,
        median: 200,
        ninety_percentile: 300,
        throughput: 400
      )
      create(
        :calculated_requests_result,
        result_id: result3.id,
        label: label,
        mean: 1000,
        median: 2000,
        ninety_percentile: 3000,
        throughput: 4000
      )

      trend_report = TrendReport.new(result1, result3)

      expected_data = {
        mean: [10, 100, 1000],
        median: [20, 200, 2000],
        ninety_percentile: [30, 300, 3000],
        throughput: [40, 400, 4000]
      }
      expect(trend_report.request_data(label)).to match(expected_data)
    end
  end

  describe '#all request_data' do
    it 'returns attributes with their values' do
      result1 = create(:result)
      result2 = create(:result)
      result3 = create(:result)
      create(
          :requests_result,
          result_id: result1.id,
          label: 'GET TEST',
          value: 1000
      )
      create(
          :requests_result,
          result_id: result1.id,
          label: 'root TEST',
          value: 30
      )
      create(
          :requests_result,
          result_id: result2.id,
          label:  'GET TEST',
          value: 120
      )
      create(
          :requests_result,
          result_id: result2.id,
          label:  'root TEST',
          value: 2
      )
      create(
          :requests_result,
          result_id: result3.id,
          label:  'GET TEST',
          value: 120
      )
      create(
          :requests_result,
          result_id: result3.id,
          label:  'root TEST',
          value: 2
      )
      trend_report = TrendReport.new(result1, result3)

      expected_data = {
          mean: [515.0, 61.0, 61.0],
          median: [515.0, 61.0, 61.0],
          ninety_percentile: [515.0, 61.0, 61.0],
          throughput: [2.0, 2.0, 2.0]
      }
      expect(trend_report.all_requests_data).to match(expected_data)
    end
  end

  describe '#sorted_labels_by_mean_trend' do
    it 'returns labels sorted by mean trend' do
      result1 = create(:result)
      create(:calculated_requests_result, result_id: result1.id, label: 'a', mean: 1)
      create(:calculated_requests_result, result_id: result1.id, label: 'b', mean: 100)
      create(:calculated_requests_result, result_id: result1.id, label: 'c', mean: 1)
      result2 = create(:result)
      create(:calculated_requests_result, result_id: result2.id, label: 'a', mean: 999)
      create(:calculated_requests_result, result_id: result2.id, label: 'b', mean: 999)
      create(:calculated_requests_result, result_id: result2.id, label: 'c', mean: 999)
      result3 = create(:result)
      create(:calculated_requests_result, result_id: result3.id, label: 'a', mean: 2)
      create(:calculated_requests_result, result_id: result3.id, label: 'b', mean: 90)
      create(:calculated_requests_result, result_id: result3.id, label: 'c', mean: 1)

      trend_report = TrendReport.new(result1, result3)

      expect(trend_report.sorted_labels_by_mean_trend).to match([['a', 100.00], ['c', 0.00], ['b', -10.00]])
    end
  end

  describe '#performance_labels' do
    it 'return all performance labels' do
      result1 = create(:result)
      create(:calculated_performance_result, result_id: result1.id, label: 'web00 CPU Processor Time')
      result2 = create(:result)
      create(:calculated_performance_result, result_id: result2.id, label: 'web11 CPU Processor Time')
      result3 = create(:result)
      create(:calculated_performance_result, result_id: result3.id, label: 'web22 EXEC NetworkBytes Sent/sec')
      trend_report = TrendReport.new(result1, result3)
      expect(trend_report.performance_labels).to match_array(['web00 CPU Processor Time', 'web11 CPU Processor Time', 'web22 EXEC NetworkBytes Sent/sec'])
    end

  end
end
