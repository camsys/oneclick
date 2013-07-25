Oneclick::Application.routes.draw do

  scope "(:locale)", locale: /en|es/ do

    authenticated :user do
      root :to => 'home#index'
    end

    devise_for :users

    resources :users
    resources :trips, only: [:new, :create, :show]

    match '/' => 'home#index'

    root :to => "home#index"
  end


end
