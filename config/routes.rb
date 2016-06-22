Oneclick::Application.routes.draw do
  
  get '/configuration' => 'configuration#configuration'

  scope "(:locale)", locale: oneclick_available_locales do

    root to: 'home#index'

    authenticated :user do
      root :to => 'trips#new', as: :authenticated_root
    end

    devise_for :users, controllers: {registrations: "registrations", sessions: "sessions", passwords: 'passwords'}

    resources :content

    resources :messages, :only => [:create]
    post "mark_message_as_read" => "user_messages#mark_as_read", as: :read_message
    post "open_message" => "user_messages#open"

    get "user_relationships/:id/check/" => "user_relationships#check_update", as: :check_update_user_relationship # need to support client-side logic with server-side vaildations
    # everything comes under a user id
    resources :users, except: [:index] do
      member do
        get   'find_by_email'
        get   'profile'
        post  'initial_booking'
        post  'add_booking_service'
        post  'associate_service'
        # post  'update'
        get   '/assist/:buddy_id', to: 'users#assist', as: :assist
      end

      resources :characteristics, :only => [:new, :create, :edit, :update] do
        collection do
          get 'header'
          post 'update'
        end
        member do
          put 'set'
        end
      end

      resources :sidewalk_obstructions, :only => [:create, :update] do
        collection do
          post "approve"
          post "reject"
          post "delete"
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

      resources :agency_user_relationships, controller: 'admin/agency_user_relationships', :only => [:create,:destroy] do
        member do
          get   'traveler_revoke'
          get   'traveler_hide'
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
          post 'handle'
          get   'search'
          post  'geocode'
        end
      end

      # users have trips
      resources :trips, :only => [:show, :index, :new, :create, :destroy, :edit, :update] do
        get 'multi_od_grid/:multi_od_trip_id' => 'trips#multi_od_grid', as: 'multi_od_grid'
        resources :characteristics, only: [:new, :update], controller: 'characteristics'
        collection do
          post  'set_traveler'
          get   'unset_traveler'
          get   'search'
          post  'geocode'
          get   'plan_map'
          get   'create_multi_od'
        end
        member do
          get   'populate'
          get   'repeat'
          get   'select'
          get   'details'
          get   'itinerary'
          post  'email'
          post  'email_provider'
          post  'email_itinerary'
          get   'email_itinerary2_values'
          post  'email2'
          get   'hide'
          get   'unhide_all'
          get   'skip'
          post  'comments'
          post  'admin_comments'
          get   'show_printer_friendly'
          get   'example'
          get   'book'
          get   'plan'
          post  'cancel'
          get   'serialize_trip'
        end
        resources :itineraries do
          member do
            get 'map_status'
            get 'request_create_map'
            get 'create_map'
            post 'book'
          end
        end
        resources :trip_parts do
          member do
            get 'reschedule'
          end
        end
      end

      resources :trip_parts do
        member do
          get 'itineraries'
          get 'unhide_all'
          get 'unselect_all'
        end
      end

      resources :user_services do
        member do
          post 'update'
          post 'create'
        end
      end
    end

    resources :providers do
      collection do
        get 'index'
      end
    end

    # scope('/kiosk') do
    #   devise_for :users, as: 'kiosk', controllers: {sessions: "kiosk/sessions"}
    # end

    # get '/kiosk_user/kiosk/users/sign_in', to: 'kiosk/sessions#create'


    get 'place_details/:id' => 'place_searching#details', as: 'place_details'
    get 'reverse_geocode' => 'place_searching#reverse_geocode', as: 'reverse_geocode'

    get '/place_search' => 'trips#search'
    get '/place_search_my' => 'trips#search_my'
    get '/place_search_poi' => 'trips#search_poi'
    get '/place_search_geo' => 'trips#search_geo'

    # reporting engine
    namespace :reporting do
      get '/'  => 'reports#index'
      resources :reports, only: [:index, :show] do
        resources :results, only: [:index]
      end
    end

    namespace :admin do

      get '/reports/trips_datatable' => 'reports#trips_datatable'
      post '/reports/update_reports_data' => 'reports#update_reports_data'

      resources :reports, :only => [:index, :show] do
        get 'results'
      end

      resources :trips, :only => [:index]
      resources :trip_parts, :only => [:index]
      get '/geocode' => 'util#geocode'
      get '/raise' => 'util#raise'
      get '/services' => 'util#services'
      get '/settings' => 'util#settings'
      patch '/load_pois' => 'pois#load_pois'
      get '/check_loading_status' => 'pois#check_loading_status'
      patch '/upload_application_logo' => 'util#upload_application_logo'
      patch '/upload_favicon' => 'util#upload_favicon'
      get '/' => 'admin_home#index'
      resources :sidewalk_obstructions, :only => [:index] do
        collection do
          patch "approve"
        end
      end
      resources 'agency_user_relationships' do
        get   'aid_user'
        get   'agency_revoke'
      end
      resources :agencies do
        get 'find_agent_by_email'
        get 'travelers'
        get "users/:id/agency_assist", to: "users#assist", as: :agency_assist
        resources 'agency_user_relationships' do
          get   'agency_revoke'
        end
        get 'select_user'
        member do
          patch 'undelete'
        end
        resources :trips
      end
      resources :users do
        get 'merge', on: :member, to: "users#merge_edit"
        patch 'merge', on: :member, to: "users#merge_submit"
        put 'update_roles', on: :member
        get 'find_by_email'
        member do
          patch 'undelete'
        end
      end
      resources :providers do
        get   'find_staff_by_email'
        resources :users
        resources :services
        resources :trips, only: [:index, :show]
        member do
          patch 'undelete'
        end
        resources :trip_parts
      end
      resources :translations
      resources :oneclick_configurations
    end#admin

    resources :services do
      resources :fare_zones, only: [:create]
      collection do
        get 'authenticate_booking_settings'
      end

      member do
        get 'fare_type_form'
        patch 'undelete'
        get 'view'

      end
    end

    resources :satisfaction_surveys

    resources :trips do
      member do
        get 'itinerary_map'
      end
    end
    get "plan_a_trip" => 'trips#plan_a_trip'

    resources :esp_reader do
      collection do
        get 'upload'
        get 'confirm'
        get 'build_polygons'
        post 'update'
      end
    end

    get '/' => 'home#index'

    get '/404' => 'errors#error_404', as: 'error_404'
    get '/422' => 'errors#error_422', as: 'error_422'
    get '/500' => 'errors#error_500', as: 'error_500'
    get '/501' => 'errors#error_501', as: 'error_501'

  end


  #API
  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :trip_purposes do
        collection do
          post 'list' => 'trip_purposes#list'
          post 'index' => 'trip_purposes#index'
        end
      end

      resources :itineraries do
        collection do
          post 'select'
          post 'plan'
          post 'book'
          post 'cancel'
          post 'email'
          post 'request_create_maps'
          post 'map_status'
        end

        member do
          get 'create_map'
        end
      end

      resources :trips do
        collection do
          get 'status_from_token'
          get 'details_from_token'
          get 'list'
          get 'index'
        end

        member do
          get 'status'
          get 'details'
        end
      end

      resources :places do
        collection do
          get 'search'
          post 'within_area'
          get 'boundary'
          get 'routes'
        end
      end

      resources :characteristics do
        collection do
          get 'list'
          get 'index'
        end
      end

      resources :accommodations do
        collection do
          get 'list'
          get 'index'
        end
      end

      resources :users do
        collection do
          post 'update'
          get  'profile'
        end
      end

      devise_scope :user do
        post 'sign_in' => 'sessions#create'
        post 'sign_out' => 'sessions#destroy'
      end

    end
  end

  get 'heartbeat' => Proc.new { [200, {'Content-Type' => 'text/plain'}, ['ok']] }

  get '/robots.txt' => RobotsTxt
end
