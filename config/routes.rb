Rails.application.routes.draw do
  root 'results#index'


  resources :results do
    put 'toggle'
    member do
      get 'download_requests_data'
      get 'download_performance_data'
      get 'report'
    end
  end
  post 'result/performance_plot' => 'results#performance_plot'
  post 'result/requests_seconds_to_values_plot' => 'results#requests_seconds_to_values_plot'
  post 'result/requests_histogram_plot' => 'results#requests_histogram_plot'
  post 'result/all_requests_histogram_plot' => 'results#all_requests_histogram_plot'
  post 'result/percentile_requests_plot' => 'results#percentile_requests_plot'

  namespace :api do
    resources :results, only: [:create]
  end

  get 'compare' => 'compare#show'
  namespace 'compare' do
    post 'requests_histogram_plot'
    post 'requests_seconds_to_values_plot'
    post 'all_requests_histogram_plot'
    post 'percentile_requests_plot'
    post 'performance_plot'
  end

  get 'trend' => 'trend#show'
  namespace 'trend' do
    post 'requests_plot'
    post 'all_requests_stats_plot'
  end
end
