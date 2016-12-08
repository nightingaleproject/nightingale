Rails.application.routes.draw do
  resources :causes_of_deaths
  resources :cause_of_deaths
  resources :decedents
  resources :death_records

  use_doorkeeper

  devise_for :users

  authenticated :user do
    root :to => 'death_records#index', :as => :authenticated_root
  end
  root :to => redirect('/users/sign_in')
end
