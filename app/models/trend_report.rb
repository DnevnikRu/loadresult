class TrendReport
  attr_reader :results

  def initialize(results)
    @results = results
  end

  def description_differences
    diff = []
    @results.each do |result|
      if diff.empty? ||
         diff.last[:duration] != result.duration ||
         diff.last[:rps] != result.rps ||
         diff.last[:profile] != result.profile ||
         diff.last[:time_cutting_percent] != result.time_cutting_percent
        diff.push(
          ids: [result.id],
          duration: result.duration,
          rps: result.rps,
          profile: result.profile,
          time_cutting_percent: result.time_cutting_percent
        )
      else
        diff.last[:ids].push result.id
      end
    end
    diff
  end
end
