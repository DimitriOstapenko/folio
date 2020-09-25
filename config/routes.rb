Rails.application.routes.draw do

  root 'quotes#index'

  devise_for :users

  resources :quotes #, :users
  resources :portfolios do
    resources :positions #, only: [:index, :show, :create, :destroy]
  end

end
