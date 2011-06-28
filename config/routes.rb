Metaldetectr::Application.routes.draw do
  root :to => 'releases#index'

  devise_for :users
  resources :releases
  resources :lastfm_users

  namespace :admin do
    resources :releases
  end
end
