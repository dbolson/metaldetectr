Metaldetectr::Application.routes.draw do
  root :to => 'releases#index'

  devise_for :users
  resources :releases
  resources :lastfm_users

  #get 'users/edit'
  #post 'users/update'
end
