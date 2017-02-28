Rails.application.routes.draw do
  resources :causes_of_deaths
  resources :cause_of_deaths
  resources :death_records do
    resources :steps, only: [:show, :update], controller: 'death_record/steps'
    resources :comments
  end

  use_doorkeeper

  devise_for :users, :controllers => {:registrations => "registrations", :passwords => "passwords"}

  resources :guest_users, param: :guest_user_token, controller: 'guest_users'

  resources :questions

  match 'questions/create' => 'questions#create', :via => :get

  match 'questions/build' => 'questions#build', :via => :put

  resources :reports

  resources :charts, only: [:create] do
    collection do
      get 'by_day'
    end
  end

  resources :admins

  resources :users do
    member do
      get 'delete'
    end
  end

  authenticated :user do
    root :to => 'death_records#index', :as => :authenticated_root
  end
  root :to => redirect('/users/sign_in')
end
