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
    resources :users, only: [:index, :show] do
      get :posts, to: 'other_user_posts#index'
      get :likes, to: 'user_likes#index'
      get :followers, to: 'other_user_followers#followers'
      get :following, to: 'other_user_followers#following'
    end
    resources :s3_presigned_url, only: [:index]
    resources :posts do
      resources :likes, only: :index
      resources :comments, only: [:index, :create]
      resources :flags, only: :create
    end
    resources :comments, only: [:update, :destroy]

    resources :hash_tags, only: :show do
      get :posts, to: 'hash_tag_posts#index'
    end

    post 'follow/:user_id', to: 'follows#create'
    delete 'follow/:user_id', to: 'follows#destroy'

    get 'followers', to: 'followers#followers'
    get 'following', to: 'followers#following'

    get 'search/users/:term', to: 'search#users'
    get 'search/hash_tags/:term', to: 'search#hash_tags'

    get 'timeline', to: 'timeline#index'
    get 'public_timeline', to: 'public_timeline#index'

    post 'like/:post_id', to: 'like#create'
    delete 'like/:post_id', to: 'like#destroy'

    namespace :admin do
      resources :stats, only: :index
      resources :flagged_posts, only: [:index, :update, :delete] do
        resources :flags, only: :index
      end
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
