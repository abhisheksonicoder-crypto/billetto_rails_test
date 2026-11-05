Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :events, only: [ :index, :show ] do
    resource :vote, only: :create
  end

  get "sign_in", to: "sessions#new"
  get "sign_up", to: "registrations#new"

  if Rails.env.development?
    mount RailsEventStore::Browser => "/res"
  end

  root "events#index"
end
