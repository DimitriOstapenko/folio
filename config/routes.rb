Rails.application.routes.draw do

  root 'portfolios#index'

  devise_for :users

  resources :quotes #, :users
  resources :portfolios do
    resources :positions #, only: [:index, :show, :create, :destroy]
  end

  get '/chart', to: 'static_pages#chart'
end
