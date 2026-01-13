Rails.application.routes.draw do
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
    end
    collection do
      get :timeline
    end
  end
  resources :abstractions
  resources :phrases
  resources :quiz_sets
  resources :quizzes
  resources :quiz_choices
  resources :scripts
  resources :experiments
  resources :concept_experiments
end
