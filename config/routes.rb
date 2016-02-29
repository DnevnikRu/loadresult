Rails.application.routes.draw do
  resources :results, only: [:index, :new, :create]
  get 'compare' => 'compare#show'
  post 'compare/requests_histogram_plot' => 'compare#requests_histogram_plot'
  post 'compare/all_requests_histogram_plot' => 'compare#all_requests_histogram_plot'
  post 'compare/percentile_requests_plot' => 'compare#percentile_requests_plot'
  root 'results#index'
end
