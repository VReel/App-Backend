class UserDoc
  include Swagger::Blocks

  swagger_schema :User do
    key :required, [:id, :handle, :email]
    property :id do
      key :type, :integer
      key :format, :int64
    end
    property :handle do
      key :type, :string
    end
    property :email do
      key :type, :string
    end
  end

  swagger_path '/users' do
    operation :post do
      security do
        key 'vreel-application-id', []
      end
      key :summary, 'Create new user'
      key :operationId, 'register'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Registration'
      ]
      parameter do
        key :in, :body
        key :name, :body
        key :description, 'User object to be created'
        key :required, true
        schema do
          key :'$ref', :UserInput
        end
      end
    end

    operation :get do
      key :summary, 'Get own user details'
      key :operationId, 'get_own_user'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Registration'
      ]
    end

    operation :put do
      key :summary, 'Update a user'
      key :description, 'If the password is to be updated, then all of password, password_confirmation
        and current_password must be present. Other fields can be updated without dependencies'
      key :operationId, 'delete_user'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Registration'
      ]
      parameter do
        key :in, :body
        key :name, :body
        key :description, 'User object to be updated'
        key :required, true
        schema do
          key :'$ref', :UserUpdateInput
        end
      end
    end

    operation :delete do
      key :summary, 'Delete a user'
      key :operationId, 'delete_user'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'Registration'
      ]
    end
  end

  swagger_path '/users/{userId}' do
    operation :get do
      key :summary, 'Show a user'
      key :description, 'Shows the full details of the user'
      key :operationId, 'get_user'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'User'
      ]
      parameter do
        key :name, :userId
        key :in, :path
        key :description, 'ID of user'
        key :required, true
        key :type, :string
      end
    end
  end

  swagger_path '/users/{userId}/posts' do
    operation :get do
      key :summary, 'Get posts by user'
      key :operationId, 'other_user_posts'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'User'
      ]
      parameter do
        key :in, :path
        key :name, :userId
        key :description, 'UUID of user'
        key :required, true
        key :type, :string
      end
      parameter do
        key :in, :query
        key :name, :page
        key :description, 'Gets next page of posts.'
        key :required, false
        key :type, :string
      end
    end
  end

  swagger_path '/users/{userId}/likes' do
    operation :get do
      key :summary, 'Get posts liked by user'
      key :operationId, 'other_user_liked_posts'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'User'
      ]
      parameter do
        key :in, :path
        key :name, :userId
        key :description, 'UUID of user'
        key :required, true
        key :type, :string
      end
      parameter do
        key :in, :query
        key :name, :page
        key :description, 'Gets next page of posts.'
        key :required, false
        key :type, :string
      end
    end
  end

  swagger_path '/users/{userId}/followers' do
    operation :get do
      key :summary, 'Get users that follow user'
      key :operationId, 'other_user_followers'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'User'
      ]
      parameter do
        key :in, :path
        key :name, :userId
        key :description, 'UUID of user'
        key :required, true
        key :type, :string
      end
      parameter do
        key :in, :query
        key :name, :page
        key :description, 'Gets next page of followers.'
        key :required, false
        key :type, :string
      end
    end
  end


swagger_path '/users/{userId}/following' do
    operation :get do
      key :summary, 'Get users that user follows'
      key :operationId, 'other_user_followinh'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'User'
      ]
      parameter do
        key :in, :path
        key :name, :userId
        key :description, 'UUID of user'
        key :required, true
        key :type, :string
      end
      parameter do
        key :in, :query
        key :name, :page
        key :description, 'Gets next page of following users'
        key :required, false
        key :type, :string
      end
    end
  end


  swagger_schema :UserInput do
    allOf do
      schema do
        key :required, [:handle, :email, :password, :password_confirmation]
        property :handle do
          key :type, :string
        end
        property :email do
          key :type, :string
        end
        property :password do
          key :type, :string
        end
        property :password_confirmation do
          key :type, :string
        end
        property :name do
          key :type, :string
        end
        property :profile do
          key :type, :string
        end
        property :thumbnail_key do
          key :type, :string
        end
        property :original_key do
          key :type, :string
        end
      end
    end
  end

  swagger_schema :UserUpdateInput do
    allOf do
      schema do
        property :handle do
          key :type, :string
        end
        property :password do
          key :type, :string
        end
        property :password_confirmation do
          key :type, :string
        end
        property :current_password do
          key :type, :string
        end
        property :name do
          key :type, :string
        end
        property :profile do
          key :type, :string
        end
        property :thumbnail_key do
          key :type, :string
        end
        property :original_key do
          key :type, :string
        end
      end
    end
  end
end
