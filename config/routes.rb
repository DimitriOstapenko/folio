Rails.application.routes.draw do

  root 'quotes#index'

  devise_for :users

  resources :quotes

end
