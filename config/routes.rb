Blorgh::Application.routes.draw do
  require 'multitenacy/constraints/subdomain_required'

  constraints(Multitenacy::Constraints::SubdomainRequired) do
    root :to => "posts#index"
    resources :posts, only: [:index, :show] do
      resources :comments
    end

    namespace :api do
      resources :posts do
        resources :comments
      end
    end

    namespace :admin do
      resources :posts
    end
  end
  mount Multitenacy::Engine, at: '/'
end
