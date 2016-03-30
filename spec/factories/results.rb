FactoryGirl.define do
  factory :result do
    version 'master'
    duration 600
    rps 150
    profile 'all_site'
    test_run_date '01.01.1978 00:00'
    time_cutting_percent 10
  end
end