Metaldetectr::Application.routes.draw do
  root :to => 'releases#index'

  devise_for :users
  match 'releases' => 'releases#index', :via => :get
  resources :lastfm_users

  namespace :admin do
    resources :releases
  end
end
