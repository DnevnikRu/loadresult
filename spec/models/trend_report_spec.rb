require 'rails_helper'

describe TrendReport do
  describe '#description_differences' do
    context 'when meta data is similar' do
      before do
        @result1 = create(
          :result,
          duration: 600,
          rps: 150,
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @result2 = create(
          :result,
          duration: 600,
          rps: 150,
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @trend_report = TrendReport.new([@result1, @result2])
      end

      it 'combines results' do
        expected_diff = [
          { ids: [@result1.id, @result2.id], duration: 600, rps: 150, profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 }
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
          rps: 150,
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @result2 = create(
          :result,
          version: 'master2',
          test_run_date: '02.02.1979 02:02',
          duration: 600,
          rps: 150,
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @trend_report = TrendReport.new([@result1, @result2])
      end

      it 'combines results' do
        expected_diff = [
          { ids: [@result1.id, @result2.id], duration: 600, rps: 150, profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 }
        ]
        expect(@trend_report.description_differences).to match(expected_diff)
      end
    end

    context 'when there is a difference in duration' do
      before do
        @result1 = create(
          :result,
          duration: 600,
          rps: 150,
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @result2 = create(
          :result,
          duration: 601,
          rps: 150,
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @trend_report = TrendReport.new([@result1, @result2])
      end

      it 'divides results' do
        expected_diff = [
          { ids: [@result1.id], duration: 600, rps: 150, profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 },
          { ids: [@result2.id], duration: 601, rps: 150, profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 }
        ]
        expect(@trend_report.description_differences).to match(expected_diff)
      end
    end

    context 'when there is a difference in rps' do
      before do
        @result1 = create(
          :result,
          duration: 600,
          rps: 150,
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @result2 = create(
          :result,
          duration: 600,
          rps: 151,
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @trend_report = TrendReport.new([@result1, @result2])
      end

      it 'divides results' do
        expected_diff = [
          { ids: [@result1.id], duration: 600, rps: 150, profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 },
          { ids: [@result2.id], duration: 600, rps: 151, profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 }
        ]
        expect(@trend_report.description_differences).to match(expected_diff)
      end
    end

    context 'when there is a difference in profile' do
      before do
        @result1 = create(
          :result,
          duration: 600,
          rps: 150,
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @result2 = create(
          :result,
          duration: 600,
          rps: 150,
          profile: 'all_site2',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @trend_report = TrendReport.new([@result1, @result2])
      end

      it 'divides results' do
        expected_diff = [
          { ids: [@result1.id], duration: 600, rps: 150, profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 },
          { ids: [@result2.id], duration: 600, rps: 150, profile: 'all_site2', time_cutting_percent: 10, value_smoothing_interval: 3 }
        ]
        expect(@trend_report.description_differences).to match(expected_diff)
      end
    end

    context 'when there is a difference in time_cutting_percent' do
      before do
        @result1 = create(
          :result,
          duration: 600,
          rps: 150,
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @result2 = create(
          :result,
          duration: 600,
          rps: 150,
          profile: 'all_site',
          time_cutting_percent: 11,
          value_smoothing_interval: 3
        )
        @trend_report = TrendReport.new([@result1, @result2])
      end

      it 'divides results' do
        expected_diff = [
          { ids: [@result1.id], duration: 600, rps: 150, profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 },
          { ids: [@result2.id], duration: 600, rps: 150, profile: 'all_site', time_cutting_percent: 11, value_smoothing_interval: 3 }
        ]
        expect(@trend_report.description_differences).to match(expected_diff)
      end
    end

    context 'when there is a difference in value_smoothing_interval' do
      before do
        @result1 = create(
          :result,
          duration: 600,
          rps: 150,
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 3
        )
        @result2 = create(
          :result,
          duration: 600,
          rps: 150,
          profile: 'all_site',
          time_cutting_percent: 10,
          value_smoothing_interval: 5
        )
        @trend_report = TrendReport.new([@result1, @result2])
      end

      it 'divides results' do
        expected_diff = [
          { ids: [@result1.id], duration: 600, rps: 150, profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 3 },
          { ids: [@result2.id], duration: 600, rps: 150, profile: 'all_site', time_cutting_percent: 10, value_smoothing_interval: 5 }
        ]
        expect(@trend_report.description_differences).to match(expected_diff)
      end
    end
  end

  describe '#request_labels' do
    it 'returns uniq labels in sorted way' do
      result1 = create(:result)
      create(:calculated_requests_result, result_id: result1.id, label: 'd')
      create(:calculated_requests_result, result_id: result1.id, label: 'c')
      result2 = create(:result)
      create(:calculated_requests_result, result_id: result2.id, label: 'c')
      create(:calculated_requests_result, result_id: result2.id, label: 'b')
      result3 = create(:result)
      create(:calculated_requests_result, result_id: result3.id, label: 'b')
      create(:calculated_requests_result, result_id: result3.id, label: 'a')

      trend_report = TrendReport.new([result1, result2, result3])

      expect(trend_report.request_labels).to match(%w(a b c d))
    end
  end

  describe '#ids' do
    it 'returns ids of results' do
      result1 = create(:result)
      result2 = create(:result)
      result3 = create(:result)

      trend_report = TrendReport.new([result1, result2, result3])

      expect(trend_report.ids).to match([result1.id, result2.id, result3.id])
    end
  end
end
