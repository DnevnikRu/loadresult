load(Rails.root.join('db', 'deployment_seeds.rb')) if Rails.env == 'development'

PerformanceGroup.destroy_all
PerformanceLabel.destroy_all
groups = [{
              name: 'Processor',
              units: '%',
              trend_limit: 0,
              labels: [PerformanceLabel.create(label: 'CPU Processor Time')]
          },
          {
              name: 'Requests per second',
              units: 'req/sec',
              trend_limit: 1,
              labels: [PerformanceLabel.create(label: 'EXEC ASP.NET Apps(_total_)\Req/sec')]
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
              name: 'Memory',
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
              labels: [PerformanceLabel.create(label: 'Memory\Page/sec'),
                       PerformanceLabel.create(label: 'Network\Bytes Received/sec')]
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
                       PerformanceLabel.create(label: 'Disk(inst_1)\Avg. Read Queue')]
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
