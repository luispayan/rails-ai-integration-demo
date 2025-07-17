Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  get "/", to: "products#index", as: :home

  resources :products, only: [ :index, :show ] do
    collection do
      post :search  # POST /products/search
    end
  end
end
