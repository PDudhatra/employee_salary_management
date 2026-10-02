Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :employees, only: [:index, :show, :create, :update]
      get "dashboard", to: "dashboard#show"
      get "salary_insights", to: "salary_insights#show"
    end
  end
end
