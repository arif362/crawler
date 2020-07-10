Rails.application.routes.draw do
  devise_for :users
  root 'products#index'
  resources :products do
    collection do
      post :search
    end
  end
end
