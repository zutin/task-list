Rails.application.routes.draw do
  # root "posts#index"

  namespace :api do
    resources :tasks, only: [ :index ]
  end
end
