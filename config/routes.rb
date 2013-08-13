Oneclick::Application.routes.draw do


  scope "(:locale)", locale: /en|es/ do

    authenticated :user do
      root :to => 'home#index'
    end

    devise_for :users, controllers: {registrations: "registrations"}

    resources :admins, :only => [:index]

    resources :reports, :only => [:index, :show]
    
    # everything comes under a user id
    resources :users do
      member do
        get 'profile'
        post 'update'
      end

      # users have trips
      resources :trips do
        member do
          get 'hide'
          get 'unhide_all'
          get 'details'
          post 'email'
        end
        # trips have planned trips
        resources :planned_trips do
          member do
            get 'hide'
            get 'unhide'
          end
        end
      end
      
      resources :buddies
      resources :travelers
      resources :buddy_relationships do
        member do
          get 'revoke'
        end
      end
      resources :traveler_relationships do
        member do
          get 'accept'
          get 'decline'
          get 'assist'
          get 'desist'
        end
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
