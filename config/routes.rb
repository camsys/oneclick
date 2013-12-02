Oneclick::Application.routes.draw do


  scope "(:locale)", locale: /en|es/ do

    authenticated :user do
      root :to => 'home#index'
    end

    devise_for :users, controllers: {registrations: "registrations"}

    # everything comes under a user id
    resources :users do
      member do
        get   'profile'
        post  'update'
      end

      resources :characteristics, :only => [:new, :create, :edit, :update] do
        collection do
          get 'header'
        end
        member do
          put 'set'
        end
      end

      resources :programs, :only => [:new, :create, :edit, :update] do
        member do
          put 'set'
        end
      end

      resources :accommodations, :only => [:new, :create, :edit, :update] do
        member do
          put 'set'
        end
      end

      # user relationships
      resources :user_relationships, :only => [:new, :create] do
        member do
          get   'traveler_retract'
          get   'traveler_revoke'
          get   'traveler_hide'
          get   'delegate_accept'
          get   'delegate_decline'
          get   'delegate_revoke'
        end
      end

      # users have places
      resources :places, :only => [:index, :new, :create, :destroy, :edit, :update] do
        collection do
          get   'search'
          post  'geocode'
        end
      end
      
      # users have trips
      resources :trips, :only => [:show, :index, :new, :create, :destroy, :edit, :update] do
        collection do
          post  'set_traveler'
          get   'unset_traveler'
          get   'search'
          post  'geocode'
        end
        member do
          get   'repeat'          
          get   'select'
          get   'details'
          get   'itinerary'
          post  'select'
          post  'email'
          post  'email_itinerary'
          get   'email_itinerary2_values'
          post  'email2'
          get   'hide'
          get   'unhide_all'
          get   'skip'
        end
      end

      resources :trip_parts do
        member do
          get 'unhide_all'
        end
      end

    end

    namespace :admin do
      resources :reports, :only => [:index, :show]
      match '/geocode' => 'util#geocode'
      match '/' => 'home#index'
    end
    
    match '/' => 'home#index'

    match '/404' => 'errors#error_404', as: 'error_404'
    match '/422' => 'errors#error_422', as: 'error_422'
    match '/500' => 'errors#error_500', as: 'error_500'
    match '/501' => 'errors#error_501', as: 'error_501'

    root :to => "home#index"
  end


end
