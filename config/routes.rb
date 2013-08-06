Oneclick::Application.routes.draw do


  scope "(:locale)", locale: /en|es/ do

    authenticated :user do
      root :to => 'home#index'
    end

    devise_for :users

    resources :admins, :only => [:index]
    
    resources :users do
      resources :reports, :only => [:index, :show]      
    end
    
    resources :trips, only: [:new, :create, :show] do
      member do
        get 'hide'
      end
    end

    match '/' => 'home#index'

    match '/404' => 'errors#error_404', as: 'error_404'
    match '/422' => 'errors#error_422', as: 'error_422'
    match '/500' => 'errors#error_500', as: 'error_500'
    match '/501' => 'errors#error_501', as: 'error_501'

    root :to => "home#index"
  end


end
