Rails.application.routes.draw do
  resources :results, only: [:index, :new, :create]
  get 'compare' => 'compare#show'
  post 'compare/request_chart' => 'compare#request_chart'
  root 'results#index'
end
