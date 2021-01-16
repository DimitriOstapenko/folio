Rails.application.routes.draw do

  root 'portfolios#index'
  devise_for :users

  resources :quotes #, :users
  resources :portfolios do
    get 'trades', 'dividends', 'cash', 'deposits', 'holdings', 'taxes'
    post 'taxes'
    resources :positions do 
      resources :transactions
    end
  end

  get '/chart', to: 'static_pages#chart'
end
