Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get "/help",to: "static_pages#help" #de ta co the dung help_path
  root "static_pages#home" #khi dung thi root_url
      
  # get 'users/new'
  # get 'users/create'
  # get 'users/show'
  get "/signup", to:"users#new"

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  
  resources :account_activations, only: :edit  
  # only: : edit de chi dung edit thoi

  resources :password_resets, only: [:new, :create, :edit, :update]
  # get 'password_resets/edit'
  # get 'password_resets/new'

  resources :microposts, only: [:create, :destroy]

  resources :relationships, only: [:create, :destroy]

  resources :users do
    member do
      get :following, :followers
    end
  end
end
