FactoryGirl.define do
  factory :calculated_requests_result do
    label 'login :GET '
    mean 48.8
    median 13
    ninety_percentile 57
    max 3015
    min 0
    throughput 0.96
    failed_results 1.72
  end
end
