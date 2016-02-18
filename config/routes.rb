Rails.application.routes.draw do
  resources :results, only: [:index, :new, :create]
  get 'compare' => 'compare#show'
  get 'compare/chart_example' => 'compare#chart_example'
  post 'compare/request_chart' => 'compare#request_chart'
  root 'results#index'
end
