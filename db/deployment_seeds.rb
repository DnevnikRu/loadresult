Result.destroy_all
RequestsResult.delete_all
CalculatedRequestsResult.delete_all
PerformanceResult.delete_all
CalculatedPerformanceResult.delete_all

random = Random.new(123)
results = []
25.times do |i|
  result_date = "#{random.rand(1..28)}.#{random.rand(1..12)}.2016 10:00"
  results << Result.create(project_id: Project.find_by(project_name: 'Dnevnik').id,
                           version: "master-#{i+1}",
                           duration: 20,
                           rps: 100,
                           profile: 'all_sites',
                           time_cutting_percent: random.rand(10..11),
                           test_run_date: result_date,
                           release_date: result_date,
                           created_at: result_date)
end

results.each do |result|
  ['login :GET', 'root /counters:GET', 'schools /ajax.ashx:POST:a=jme', 'root /user/:GET'].each do |label|
    20.times do |i|
      RequestsResult.create(timestamp: 1453280230000 + (i+1)*1000,
                            label: label,
                            value: (0 + random.rand(1000)),
                            response_code: [200, 500, 200, 200].sample,
                            result_id: result.id)
    end
    CalculatedRequestsResult.create(label: label,
                                    mean: (150 + random.rand(100)),
                                    median: (150 + random.rand(100)),
                                    ninety_percentile: (150 + random.rand(100)),
                                    max: (200 + random.rand(10)),
                                    min: (0 + random.rand(10)),
                                    failed_results: (0 + random.rand(10)),
                                    result_id: result.id,
                                    throughput: random.rand(0.1..0.4)
    )
  end

  ['web00 EXEC Network\Bytes Sent/sec', 'web11 EXEC Network\Bytes Sent/sec', 'web11 CPU Processor Time',
   'web00 CPU Processor Time', 'web00 Memory Memory\Available', 'web11 Memory Memory\Available'].each do |label|
    20.times do |i|
      PerformanceResult.create(timestamp: 1453280230000 + (i+1)*1000,
                               label: label,
                               value: (0 + random.rand(1000)),
                               result_id: result.id)

    end
    CalculatedPerformanceResult.create(label: label,
                                       mean: (150 + random.rand(100)),
                                       max: (200 + random.rand(10)),
                                       min: (0 + random.rand(10)),
                                       result_id: result.id
    )
  end
end
