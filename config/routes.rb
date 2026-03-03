Rails.application.routes.draw do
  # root "posts#index"

  namespace :api do
    resources :tasks, only: [ :index ]
    resources :lists, only: [ :index ]
  end
end
