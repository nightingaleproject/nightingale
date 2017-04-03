Rails.application.routes.draw do
  resources :causes_of_deaths
  resources :cause_of_deaths
  resources :death_records do
    resources :steps, only: [:show, :update], controller: 'death_record/steps'
    resources :comments
    member do
      get 'reenable'
    end
  end

  use_doorkeeper

  devise_for :users, :controllers => {:registrations => 'registrations', :passwords => 'passwords'}

  resources :guest_users, param: :guest_user_token, controller: 'guest_users'

  resources :questions
  match 'questions/create' => 'questions#create', :via => :get
  match 'questions/build' => 'questions#build', :via => :put

  match 'geographic/counties' => 'geographic#counties', :via => :get
  match 'geographic/cities' => 'geographic#cities', :via => :get
  match 'geographic/zipcodes' => 'geographic#zipcodes', :via => :get

  match 'entity/funeral_facility_details' => 'entity#funeral_facility_details', :via => :get

  resources :reports

  resources :statistics do
    collection do
      get 'line_death_records_created'
      get 'line_death_records_completed'
      get 'line_users_created'
      get 'line_user_sign_ins'
      get 'pie_death_records_by_step'
      get 'bar_death_record_time_by_step'
      get 'bar_average_completion'
      get 'pie_death_record_ages_by_range'
    end
  end

  resources :admins

  resources :users

  authenticated :user do
    root :to => 'death_records#index', :as => :authenticated_root
  end
  root :to => redirect('/users/sign_in')

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :death_records
    end
  end
end
