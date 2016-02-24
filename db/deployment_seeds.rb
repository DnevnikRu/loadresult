random = Random.new(123)
results = []
5.times do |i|
  results << Result.create(version: "master-#{i+1}",
                           duration: (i+1)*200,
                           rps: 100*(i+1),
                           profile: 'all_sites',
                           test_run_date: "0#{i+1}.02.2016 10:0#{i}",
                           created_at: "0#{i+1}.02.2016 10:0#{i}")
end

results.each do |result|
  ['login :GET', 'root /counters:GET', 'schools /ajax.ashx:POST:a=jme', 'root /user/:GET'].each do |label|
    10.times do |i|
      RequestsResult.create(timestamp: 1453280230000 + (i+1)*1000,
                            label: label,
                            value: (0 + random.rand(1000)),
                            response_code: [200, 500, 200, 200].sample,
                            result_id: result.id)

    end
  end
  ['web00 EXEC Network\Bytes Sent/sec', 'web11 EXEC Network\Bytes Sent/sec', 'web11 CPU Processor Time',
   'web00 CPU Processor Time', 'web00 Memory Memory\Available', 'web11 Memory Memory\Available'].each do |label|
    10.times do |i|
      PerformanceResult.create(timestamp: 1453280230000 + (i+1)*1000,
                               label: label,
                               value: (0 + random.rand(1000)),
                               result_id: result.id)
    end
  end
end
