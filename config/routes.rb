Rails.application.routes.draw do
  use_doorkeeper

  # User related routes
  devise_for :users, :controllers => {registrations: 'registrations', passwords: 'passwords'}

  # Guest user related routes
  resources :guest_users, only: [:show], param: :guest_user_token, controller: 'guest_users'

  # Death Record related routes
  resources :death_records, only: [:index, :show, :new, :edit, :update] do
    member do
      post :update_step
      post :update_active_step
      post :users_by_role
      post :register
      post :request_edits
      post :abandon
      post :views_validate
      get :preview_certificate
      get :final_certificate
    end
    collection do
      post :owned_death_records
      post :transferred_death_records
      post :views_validate_cod
    end
  end

  # IJE exporting GET for exporting death records as IJE
  match 'export_records_in_ije' => 'death_records#export_records_in_ije', :via => :get

  # IJE and FHIR exporting GETs for exporting single death records
  match 'export_record_in_ije' => 'death_records#export_record_in_ije', :via => :get
  match 'export_record_in_fhir_json' => 'death_records#export_record_in_fhir_json', :via => :get
  match 'export_record_in_fhir_xml' => 'death_records#export_record_in_fhir_xml', :via => :get

  # Step related routes
  resources :step, only: [:update]

  # Comment related routes
  resources :comments, only: [:create, :destroy]

  # Geography related routes
  match 'geography_full' => 'geography#geography_full', :via => :post
  match 'geography_short' => 'geography#geography_short', :via => :post

  # Admin related routes
  resources :admins, only: [:index]
  resources :reports, only: [:index] do
    collection do
      post :audit_logs
    end
  end
  resources :statistics
  resources :questions
  resources :users

  resources :importing, only: [:index, :error]
  match 'upload_fhir' => 'importing#upload_fhir', :via => :post
  match 'importing_error' => 'importing#error', :via => :get

  # Reports related to Nightingale records routes
  resources :analysis
  match 'analyze_causes' => 'analysis#analyze_causes', :via => :post

  # Statistics related routes
  resources :statistics do
    collection do
      post 'line_death_records_created'
      post 'line_death_records_completed'
      post 'line_users_created'
      post 'line_user_sign_ins'
      post 'pie_death_records_by_step'
      post 'bar_death_record_time_by_step'
      post 'bar_average_completion'
      post 'pie_death_record_ages_by_range'
    end
  end

  # Simple POST create API
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :death_records
    end
  end

  # FHIR API
  namespace :fhir, defaults: { format: :json } do
    namespace :v1 do
      resources :death_records
    end
  end
  # Handle OPTIONS for CORS preflight
  match '/fhir/v1/death_records' => 'fhir/v1/death_records#options', via: :options

  # Default route
  authenticated :user do
    root :to => 'death_records#index', :as => :authenticated_root
  end
  root :to => redirect('/users/sign_in')
end
