Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  resources :concepts do
    member do
      post :generate_experiment
      post :generate_phrases
      post :generate_example
    end
    collection do
      get :timeline
    end
  end
  resources :abstractions
  resources :phrases
  resources :quiz_sets
  resources :quiz_set_concepts
  resources :quizzes
  resources :quiz_choices
  resources :scripts
  resources :experiments
  resources :concept_experiments
  resources :examples
  resources :chapters

  resources :chat_rooms, only: [:index, :show, :create] do
    member do
      post :fetch_random_experiment
    end
    resources :chat_messages, only: [:index, :create]
  end

  post '/lobby/join' => 'lobby#join'
  post '/lobby/leave' => 'lobby#leave'
  get '/lobby/status' => 'lobby#status'
end
