Rails.application.routes.draw do
  root to: "application#index"
  post "/graphql", to: "graphql#execute"
end
