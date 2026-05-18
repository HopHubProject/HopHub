Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get "metrics" => "metrics#show", defaults: { format: 'txt' }

  # Browser-posted CSP violation reports (see config/initializers/content_security_policy.rb).
  post "csp-reports" => "csp_reports#create"

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

    resources :offers, path: :x do
      get 'confirm'
      delete 'destroy'
      post 'contact_emails'
    end

    resources :ride_requests, path: :r, only: [:new, :create] do
      get 'confirm'
      # GET on the destroy URL is what email-link clicks issue; it renders
      # a small confirmation page with a real DELETE form. This prevents
      # email-client prefetchers and antivirus URL scanners from
      # silently deleting users' ride requests.
      get 'destroy', action: :destroy_confirm, as: nil
      delete 'destroy'
    end
  end

  # WARNING: Only enable this route if your webserver ingress protects this
  # route from unauthorized access. The application itself has no role
  # management and allows anyone to access this route.
  ActiveAdmin.routes(self)
end
