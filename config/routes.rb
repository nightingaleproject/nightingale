Rails.application.routes.draw do
  resources :causes_of_deaths
  resources :cause_of_deaths
  resources :death_records do
    resources :steps, only: [:show, :update], controller: 'death_record/steps'
  end

  use_doorkeeper

  devise_for :users

  resources :questions

  match 'questions/create' => 'questions#create', :via => :get
  
  match 'questions/build' => 'questions#build', :via => :put

  resources :users do
    member do
      get 'become'
      get 'delete'
    end
  end

  authenticated :user do
    root :to => 'death_records#index', :as => :authenticated_root
  end
  root :to => redirect('/users/sign_in')
end
