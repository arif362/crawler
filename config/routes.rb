Rails.application.routes.draw do
  root 'products#index'
  resources :products do
    collection do
      post :search
    end
  end
end
