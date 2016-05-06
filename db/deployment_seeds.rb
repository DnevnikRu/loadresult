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
  labels = [
      'login :GET',
      'apps group /run.aspx:GET',
      'children /homework.aspx:GET',
      'children /marks.ashx:POST',
      'children /marks.aspx:GET:tab=period',
      'children /marks.aspx:GET:tab=week',
      'children /timetable.aspx:GET',
      'children :GET',
      'files /file.aspx:GET',
      'group /group.aspx:GET',
      'login /auth:GET',
      'login /logout:GET',
      'login :GET',
      'login :POST',
      'messenger /archive.aspx:GET',
      'messenger :GET',
      'root /counters:GET',
      'root /invites.aspx:GET',
      'root /user/:GET',
      'root /user/ajax.ashx:GET:a=unot',
      'root /user/ajax.ashx:POST:a=ufeed',
      'root /user/ajax.ashx:POST:t=friends',
      'root /user/calendar.aspx:GET',
      'root /user/user.aspx:GET',
      'root /user/user.aspx:GET?view=files:GET',
      'root :GET',
      'schools /ajax.ashx:POST:a=gsbgid',
      'schools /ajax.ashx:POST:a=jme',
      'schools /ajax.ashx?a=cworks:POST',
      'schools /ajax.ashx?a=jrmap:POST',
      'schools /ajaxpages/Journals/LessonPlanner.aspx:POST',
      'schools /class.aspx:GET',
      'schools /homework.aspx:GET',
      'schools /homework.aspx:GET:view=new',
      'schools /homework.aspx?choose=Показать:GET',
      'schools /journals/createhomework-cmd:POST',
      'schools /journals/journalclassical.aspx:GET:view=subject',
      'schools /journals/updatelesson-cmd:POST',
      'schools /journals:GET',
      'schools /journals:GET:tab=planning'
  ]
  labels.each do |label|
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
