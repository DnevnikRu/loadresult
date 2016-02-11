5.times do |i|
  Result.create(version: "master-#{i+1}", duration: (i+1)*200, rps: 100*(i+1), profile: 'all_sites', test_run_date: "0#{i+1}.02.2016 10:0#{i}")
end
