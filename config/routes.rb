Metaldetectr::Application.routes.draw do
  root :to => 'releases#index'
  devise_for :users
  resource :releases
end
