Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "/", to: "products#index", as: :home
  get "admin", to: "admin#index", as: :admin_home

  resources :reports, only: [ :create ]
  resources :products, only: [ :index, :show ] do
    collection do
      post :search  # POST /products/search
    end
  end
end
