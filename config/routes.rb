Rails.application.routes.draw do

  root 'portfolios#index'
  devise_for :users

  resources :quotes #, :users
  resources :portfolios do
    resources :positions do  #, only: [:index, :show, :create, :destroy]
       resources :transactions
    end
  end

  get '/chart', to: 'static_pages#chart'
  get '/all_positions', to: 'positions#all_positions'
end
