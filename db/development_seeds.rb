PerformanceGroup.destroy_all
PerformanceLabel.destroy_all
Project.destroy_all
groups = [{
              name: 'Processor',
              units: '%',
              trend_limit: 0,
              labels: [PerformanceLabel.create(label: 'CPU Processor Time'),
                       PerformanceLabel.create(label: 'CPU')]
          },
          {
              name: 'Requests per second',
              units: 'req/sec',
              trend_limit: 1,
              labels: [PerformanceLabel.create(label: 'EXEC ASP.NET Apps(_total_)\Req/sec')]
          },
          {
              name: 'Requests executing',
              units: 'requests',
              trend_limit: 0.1,
              labels: [PerformanceLabel.create(label: 'EXEC ASP.NET Apps(_total_)\Requests Executing')]
          },
          {
              name: 'Requests Current',
              units: 'requests',
              trend_limit: 0.1,
              labels: [PerformanceLabel.create(label: 'EXEC ASP.NET\Requests Current')]
          },
          {
              name: 'DB Server Connections',
              units: 'users',
              trend_limit: 1,
              labels: [PerformanceLabel.create(label: 'EXEC SQLServer User connections')]
          },
          {
              name: 'Memory Available',
              units: 'Mb',
              trend_limit: 10,
              labels: [PerformanceLabel.create(label: 'Memory Memory\Available')]
          },
          {
              name: 'Memory Page Faults',
              units: 'page/sec',
              trend_limit: 10,
              labels: [PerformanceLabel.create(label: 'Memory\Page Faults/sec')]
          },
          {
              name: 'Memory Page',
              units: 'page/sec',
              trend_limit: 1,
              labels: [PerformanceLabel.create(label: 'Memory\Page/sec')]
          },
          {
              name: 'Network traffic',
              units: 'Mb/sec',
              trend_limit: 100,
              labels: [PerformanceLabel.create(label: 'Network\Bytes Sent/sec'),
                       PerformanceLabel.create(label: 'Network\Bytes Received/sec'),
                       PerformanceLabel.create(label: 'Network I/O')]
          },
          {
              name: 'Network queue',
              units: 'unit',
              trend_limit: 0.01,
              labels: [PerformanceLabel.create(label: 'Network\Output Queue Length')]
          },
          {
              name: 'Disk queue',
              units: 'unit',
              trend_limit: 0.5,
              labels: [PerformanceLabel.create(label: 'Disk(inst_1)\Avg. Write Queue'),
                       PerformanceLabel.create(label: 'Disk(inst_1)\Avg. Read Queue'),
                       PerformanceLabel.create(label: 'Disks I/O')]
          },
          {
              name: 'Error per second',
              units: 'error/sec',
              trend_limit: 0.01,
              labels: [PerformanceLabel.create(label: 'ASP.NET Apps(_total_)\Errors Total/Sec')]
          },
          {
              name: 'Requests in application queue',
              units: 'requests',
              trend_limit: 0.01,
              labels: [PerformanceLabel.create(label: 'ASP.NET Apps(_total_)\Requests In Application Queue')]
          },
          {
              name: 'DB Server Cache',
              units: '%',
              trend_limit: 0,
              labels: [PerformanceLabel.create(label: 'SQLServer Buffer cache hit ratio'),
                       PerformanceLabel.create(label: 'SQLServer Plane cache hit ratio')]
          },
          {
              name: 'DB Server Waits',
              units: 'ms',
              trend_limit: 0.01,
              labels: [PerformanceLabel.create(label: 'SQLServer Lock Avg Wait Time')]
          },
          {
              name: 'DB Server Locks',
              units: 'locks',
              trend_limit: 0.01,
              labels: [PerformanceLabel.create(label: 'SQLServer Lock Timeouts/sec')]
          },
          {
              name: 'DB Server Statistics',
              units: 'unit',
              trend_limit: 1,
              labels: [PerformanceLabel.create(label: 'SQLServer Errors/sec'),
                       PerformanceLabel.create(label: 'SQLServer Re-Compilations/sec'),
                       PerformanceLabel.create(label: 'SQLServer Number of Deadlocks')]
          } ]
groups.each { |group| PerformanceGroup.create(group) }

Project.create(id: 1, project_name: 'Dnevnik')
Project.create(id: 2, project_name: 'Contingent')

Result.destroy_all
RequestsResult.delete_all
CalculatedRequestsResult.delete_all
PerformanceResult.delete_all
CalculatedPerformanceResult.delete_all

random = Random.new(123)
results = []
20.times do |i|
  result_date = "#{random.rand(1..28)}.#{random.rand(1..12)}.2016 10:00"
  results << Result.create(project_id: Project.find_by(project_name: 'Dnevnik').id,
                           version: "master-#{i+1}",
                           duration: 20,
                           rps: 100,
                           profile: 'all_sites',
                           data_version: (1 if random.rand(0..100) < 95),
                           time_cutting_percent: (random.rand(0..100) < 95 ? 11 : 10),
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
