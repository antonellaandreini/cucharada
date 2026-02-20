Rails.application.routes.draw do
  root "pages#home"

  # Authentication
  get    "login",    to: "sessions#new",            as: :login
  post   "login",    to: "sessions#create"
  delete "logout",   to: "sessions#destroy",         as: :logout
  get    "registro", to: "registrations#new",        as: :signup
  post   "registro", to: "registrations#create"

  # Recipes
  resources :recipes, path: "recetas" do
    resource :rating, only: [ :create ]
    resources :comments, only: [ :create, :destroy ]
    resources :cook_photos, only: [ :create, :destroy ]
    get :cocinar, on: :member, action: :cooking_mode
  end
  get "mis-recetas", to: "recipes#my_recipes", as: :my_recipes

  # Shopping lists
  resources :shopping_lists, path: "listas" do
    member do
      patch :toggle_item
      delete :remove_item
      post :add_recipe
      post :add_item
    end
    collection do
      get :download_pdf
    end
  end

  # Search by ingredients
  get "buscar", to: "search#index", as: :search

  # Favorites
  resources :favorites, path: "favoritos", only: [ :index, :create, :destroy ]

  # Ingredient autocomplete
  get "ingredientes/buscar", to: "ingredients#search", as: :search_ingredients

  # PWA
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
