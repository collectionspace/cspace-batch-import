# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, skip: [:passwords] # TODO: :registrations if configured
  root 'sites#home'
  resources :groups, only: %i[index create update]
  resources :mappers, only: %i[index]
  get '/mappers/autocomplete', to: 'mappers#autocomplete'
  resources :users, except: %i[create new show] do
    post :impersonate, on: :member
    post :stop_impersonating, on: :collection
  end
  get '/users/:id', to: redirect('/users/%{id}/edit')
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
