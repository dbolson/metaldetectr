Metaldetectr::Application.routes.draw do
  root :to => 'releases#index'

  devise_for :users
  resources :releases

  get 'users/edit'
  post 'users/update'
end
