Rails.application.routes.draw do
  get '/altcha', to: 'altcha#new'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "metrics" => "metrics#show", defaults: { format: 'txt' }

  # Defines the root path route ("/")
  root "home#index"

  get "imprint" => "contents#imprint"
  get "privacy" => "contents#privacy"
  get "tos"     => "contents#tos"

  get 'postal_code_search'=> 'geonames#postal_code_search'

  resources :gdpr_inquiries, only: [:new, :create]
  get "gdpr" => "gdpr_inquiries#new"

  resources :events, path: :e do
    get 'geojson'
    get 'confirm'
    delete 'destroy'

    resources :entries, path: :x do
      get 'confirm'
      delete 'destroy'
      post 'contact_emails'
    end
  end

  # WARNING: Only enable this route if your webserver ingress protects this
  # route from unauthorized access. The application itself has no role
  # management and allows anyone to access this route.
  ActiveAdmin.routes(self)
end
