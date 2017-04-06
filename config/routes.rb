Rails.application.routes.draw do
  root 'home#index'

  get 'v1', to: 'home#index'

  mount_devise_token_auth_for 'User',
                              at: '/v1/users',
                              skip: [:omniauth_callbacks],
                              controllers: {
                                registrations: 'users/registrations',
                                sessions: 'users/sessions',
                                confirmations: 'users/confirmations',
                                passwords: 'users/passwords'
                              }

  resources :apidocs, only: [:index]

  namespace :v1, defaults: { format: 'json' } do
    resources :users, only: [:index, :show]
    resources :s3_presigned_url, only: [:index]
    resources :posts
    resources :stats, only: :index
    get 'search/users/:term', to: 'search#users'
    get 'search/hash_tags/:term', to: 'search#hash_tags'
    get 'posts/hash_tags/:hash_tag', to: 'post_hash_tags#posts_with_hash_tag', as: :post_hash_tags
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
