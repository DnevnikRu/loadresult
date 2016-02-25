Rails.application.routes.draw do
  resources :results, only: [:index, :new, :create]
  get 'compare' => 'compare#show'
  post 'compare/histogram_requests_plot' => 'compare#histogram_requests_plot'
  root 'results#index'
end
