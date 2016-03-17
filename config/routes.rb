Rails.application.routes.draw do
  root 'results#index'
  resources :results
  post 'results/new' => 'results#create'
  get 'compare' => 'compare#show'
  namespace 'compare' do
    post 'requests_histogram_plot'
    post 'all_requests_histogram_plot'
    post 'percentile_requests_plot'
    post 'performance_plot'
  end
end
