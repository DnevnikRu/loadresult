Rails.application.routes.draw do
  root 'results#index'

  resources :results do
    put 'toggle'
    get 'download_requests_data'
    get 'download_performance_data'
  end

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
end
