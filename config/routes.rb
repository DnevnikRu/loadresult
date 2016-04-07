Rails.application.routes.draw do
  root 'results#index'

  resources :results do
    put 'toggle'
    get 'download_summary'
  end

  get 'compare' => 'compare#show'
  namespace 'compare' do
    post 'requests_histogram_plot'
    post 'requests_seconds_to_values_plot'
    post 'all_requests_histogram_plot'
    post 'percentile_requests_plot'
    post 'performance_plot'
  end
end
